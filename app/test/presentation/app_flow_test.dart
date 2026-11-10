import 'package:coop_assistant/data/auth/session_store.dart';
import 'package:coop_assistant/data/local/app_database.dart';
import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/data/repositories/product_repository.dart';
import 'package:coop_assistant/data/repositories/purchase_repository.dart';
import 'package:coop_assistant/data/repositories/shopping_list_repository.dart';
import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:coop_assistant/domain/model/product.dart';
import 'package:coop_assistant/domain/model/purchase_line.dart';
import 'package:coop_assistant/domain/prices/price_history.dart';
import 'package:coop_assistant/presentation/app.dart';
import 'package:coop_assistant/presentation/product/price_chart.dart';
import 'package:coop_assistant/presentation/session/session_cubit.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements CoopApi {}

const _server = CoopServer(
  name: 'Le Chaudron',
  baseUrl: 'https://coop.example',
  apiBase: '/coop_app/v1',
  features: ['purchases'],
);
const _session = Session(server: _server, token: 'tok');

Member _member({required bool consent}) => Member(name: 'Alice', purchaseHistoryConsent: consent);

/// Coffee bought weekly, last time eight days ago: due today.
List<PurchaseLine> _weeklyCoffee() {
  final today = DateTime.now();
  return [
    for (final (index, daysAgo) in [29, 22, 15, 8].indexed)
      PurchaseLine(
        id: index + 1,
        orderId: index + 1,
        date: DateTime(today.year, today.month, today.day - daysAgo, 12),
        productId: 5,
        productName: 'Café moulu 250g',
        uom: 'Units',
        qty: 1,
        totalIncl: 4.9,
      ),
  ];
}

void main() {
  late _MockApi api;
  late AppDatabase db;
  late InMemorySessionStore store;
  late PurchaseRepository purchases;
  late ProductRepository products;
  late ShoppingListRepository shoppingList;

  setUpAll(() async {
    registerFallbackValue(_session);
    registerFallbackValue(_server);
    await initializeDateFormatting('fr');
  });

  setUp(() {
    api = _MockApi();
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    store = InMemorySessionStore();
    purchases = PurchaseRepository(db, api);
    products = ProductRepository(db, api);
    shoppingList = ShoppingListRepository(db);
    serveCatalogue(api, const []);
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    final session = SessionCubit(
      api: api,
      store: store,
      clearLocalData: () async {
        await purchases.clear();
        await products.clear();
        await shoppingList.clear();
      },
      deviceName: 'test',
    );
    await tester.pumpWidget(
      CoopAssistantApp(
        session: session,
        api: api,
        purchases: purchases,
        products: products,
        shoppingList: shoppingList,
      ),
    );
    await tester.runAsync(session.restore);
    await settle(tester);
  }

  void servePurchases(List<PurchaseLine> lines) => when(
    () => api.purchases(any(), cursor: any(named: 'cursor')),
  ).thenAnswer((_) async => PurchasePage(lines: lines, nextCursor: 'c1', hasMore: false));

  testWidgets('from choosing the cooperative to hiding a suggestion and logging out', (tester) async {
    when(() => api.discover(any())).thenAnswer((_) async => _server);
    when(
      () => api.login(
        any(),
        login: any(named: 'login'),
        password: 'wrong',
        deviceName: any(named: 'deviceName'),
      ),
    ).thenThrow(const CoopApiException('INVALID_CREDENTIALS'));
    when(() => api.login(any(), login: 'alice', password: 'secret', deviceName: 'test')).thenAnswer((_) async => 'tok');
    when(() => api.me(any())).thenAnswer((_) async => _member(consent: false));
    when(() => api.setPurchaseHistoryConsent(any(), enabled: true)).thenAnswer((_) async => _member(consent: true));
    when(() => api.logout(any())).thenAnswer((_) async {});
    servePurchases(_weeklyCoffee());

    await pumpApp(tester);

    // The cooperative.
    expect(find.text('Votre coopérative'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'coop.example');
    await tap(tester, 'Continuer');
    verify(() => api.discover('coop.example')).called(1);
    expect(find.text('Le Chaudron'), findsOneWidget);

    // Login: a refusal is explained, then the right password goes through.
    await tester.enterText(find.widgetWithText(TextField, 'Identifiant'), 'alice');
    await tester.enterText(find.widgetWithText(TextField, 'Mot de passe'), 'wrong');
    await tap(tester, 'Se connecter');
    expect(find.text('Identifiant ou mot de passe incorrect.'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Mot de passe'), 'secret');
    await tap(tester, 'Se connecter');
    expect(store.token, 'tok');

    // Nothing is read before the member agrees.
    expect(find.text("Utiliser votre historique d'achats ?"), findsOneWidget);
    verifyNever(() => api.purchases(any(), cursor: any(named: 'cursor')));
    await tap(tester, "Activer l'historique d'achats");

    expect(find.text('Café moulu 250g'), findsOneWidget);
    expect(find.text('À racheter'), findsNWidgets(3), reason: 'screen title, tab and status chip');
    expect(find.textContaining('Habituellement 1 tous les 7 jours'), findsOneWidget);
    expect(find.textContaining('4,90'), findsOneWidget);

    // Hide it.
    await tester.tap(find.descendant(of: find.byType(ListTile), matching: find.byType(PopupMenuButton<void>)));
    await settle(tester);
    await tap(tester, 'Ne plus proposer');
    expect(find.text('Café moulu 250g'), findsNothing);
    expect(find.text("Rien à racheter pour l'instant."), findsOneWidget);

    // Log out: token revoked, cache dropped, back to the login of the same cooperative.
    await tester.tap(find.byKey(const ValueKey('account-menu')));
    await settle(tester);
    await tap(tester, 'Se déconnecter');
    verify(() => api.logout(any())).called(1);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.text('Le Chaudron'), findsOneWidget);
    expect(store.token, isNull);
    expect(await tester.runAsync(() => purchases.watchLines().first), isEmpty);
  });

  testWidgets('a returning member with consent sees their suggestions directly', (tester) async {
    store
      ..server = _server
      ..token = 'tok';
    when(() => api.me(any())).thenAnswer((_) async => _member(consent: true));
    servePurchases(_weeklyCoffee());

    await pumpApp(tester);

    expect(find.text('Café moulu 250g'), findsOneWidget);
  });

  testWidgets('a refused token sends the member back to the login screen', (tester) async {
    store
      ..server = _server
      ..token = 'tok';
    when(() => api.me(any())).thenThrow(const CoopApiException(CoopApiException.unauthorized));

    await pumpApp(tester);

    expect(find.text('Se connecter'), findsOneWidget);
    expect(store.token, isNull);
  });

  testWidgets('offline, the cached suggestions stay visible with a retry banner', (tester) async {
    store
      ..server = _server
      ..token = 'tok';
    when(() => api.me(any())).thenAnswer((_) async => _member(consent: true));
    servePurchases(_weeklyCoffee());
    await tester.runAsync(() => purchases.sync(_session));
    when(() => api.me(any())).thenThrow(const CoopApiException(CoopApiException.network));

    await pumpApp(tester);

    expect(find.text('Café moulu 250g'), findsOneWidget);
    expect(find.textContaining('Connexion impossible'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });

  group('catalogue', () {
    const catalogue = [
      Product(id: 5, name: 'Café moulu 250g', category: 'Épicerie', uom: 'Units', priceIncl: 5.3, barcode: '376'),
      Product(id: 6, name: 'Pâtes complètes 500g', category: 'Épicerie', uom: 'Units', priceIncl: 1.85),
      Product(id: 7, name: 'Carottes', category: 'Fruits et légumes', uom: 'kg', priceIncl: 2.4),
    ];

    setUp(() {
      store
        ..server = _server
        ..token = 'tok';
      when(() => api.me(any())).thenAnswer((_) async => _member(consent: true));
      servePurchases(_weeklyCoffee());
      serveCatalogue(api, catalogue);
    });

    testWidgets('lists the products, searches without accents and filters by category', (tester) async {
      await pumpApp(tester);
      await tap(tester, 'Catalogue');

      expect(find.text('Pâtes complètes 500g'), findsOneWidget);
      expect(find.text('Carottes'), findsOneWidget);
      expect(find.textContaining('/ kg'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'pates');
      await settle(tester);
      expect(find.text('Pâtes complètes 500g'), findsOneWidget);
      expect(find.text('Carottes'), findsNothing);

      await tester.enterText(find.byType(TextField), 'introuvable');
      await settle(tester);
      expect(find.text('Aucun produit ne correspond à votre recherche.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.byTooltip('Filtrer par catégorie'));
      await settle(tester);
      await tap(tester, 'Fruits et légumes');
      expect(find.text('Carottes'), findsOneWidget);
      expect(find.text('Pâtes complètes 500g'), findsNothing);
    });

    testWidgets('a product shows its current price and how it moved', (tester) async {
      await pumpApp(tester);
      await tap(tester, 'Catalogue');
      await tap(tester, 'Café moulu 250g');

      expect(find.text('Évolution du prix'), findsOneWidget);
      expect(find.text('Code-barres 376'), findsOneWidget);
      expect(find.byType(PriceChart), findsOneWidget);
      // Paid 4,90 € at the till, then seen at 5,30 € in the catalogue.
      expect(find.textContaining('prix payé'), findsOneWidget);
      expect(find.textContaining('· prix du catalogue'), findsOneWidget);
      expect(find.textContaining('+0,40'), findsOneWidget);
      expect(find.textContaining('Dernier achat le'), findsOneWidget);
    });

    testWidgets('a suggestion opens its product, even once it left the catalogue', (tester) async {
      serveCatalogue(api, const []);
      await pumpApp(tester);
      await tap(tester, 'Café moulu 250g');

      expect(find.text("Ce produit n'est plus au catalogue."), findsOneWidget);
      expect(find.byType(PriceChart), findsOneWidget);
      expect(find.textContaining('prix payé'), findsOneWidget);
    });

    testWidgets('an unavailable catalogue is explained with a retry', (tester) async {
      when(
        () => api.products(any(), cursor: any(named: 'cursor')),
      ).thenThrow(const CoopApiException(CoopApiException.network));
      await pumpApp(tester);
      await tap(tester, 'Catalogue');

      expect(find.text("Le catalogue n'a pas encore pu être chargé."), findsOneWidget);
      expect(find.textContaining('Connexion impossible'), findsOneWidget);
    });
  });

  group('shopping list', () {
    const catalogue = [
      Product(id: 5, name: 'Café moulu 250g', category: 'Épicerie', uom: 'Units', priceIncl: 4.9),
      Product(id: 7, name: 'Carottes', category: 'Fruits et légumes', uom: 'kg', priceIncl: 2.4),
    ];

    setUp(() {
      store
        ..server = _server
        ..token = 'tok';
      when(() => api.me(any())).thenAnswer((_) async => _member(consent: true));
      when(() => api.logout(any())).thenAnswer((_) async {});
      servePurchases(_weeklyCoffee());
      serveCatalogue(api, catalogue);
    });

    Future<List<(String, double, bool)>> stored(WidgetTester tester) async => [
      for (final item in (await tester.runAsync(() => shoppingList.watchItems().first))!)
        (item.label, item.quantity, item.checked),
    ];

    testWidgets('starts empty and explains how to fill it', (tester) async {
      await pumpApp(tester);
      await tap(tester, 'Liste');

      expect(find.text('Ma liste'), findsOneWidget);
      expect(find.textContaining('Votre liste est vide.'), findsOneWidget);
      expect(find.text('Total estimé'), findsNothing);
    });

    testWidgets('gathers suggestions, catalogue products and free lines, with an estimated total', (tester) async {
      await pumpApp(tester);

      // From a suggestion, with the usual quantity.
      await tester.tap(find.byTooltip('Ajouter Café moulu 250g à la liste'));
      await settle(tester);
      expect(find.textContaining('ajouté à la liste'), findsOneWidget);

      // From the catalogue: half a kilogram of a product sold by weight.
      await tap(tester, 'Catalogue');
      await tester.tap(find.byTooltip('Ajouter Carottes à la liste'));
      await settle(tester);

      await tap(tester, 'Liste');
      await tester.enterText(find.byType(TextField).hitTestable(), 'Pain');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await settle(tester);

      expect(await stored(tester), [('Café moulu 250g', 1.0, false), ('Carottes', 0.5, false), ('Pain', 1.0, false)]);
      expect(find.text('0,5 kg'), findsOneWidget);
      // 4,90 + 0,5 × 2,40
      expect(find.text('Total estimé'), findsOneWidget);
      expect(find.textContaining('6,10'), findsOneWidget);
      expect(find.text('hors 1 article sans prix'), findsOneWidget);
      // The tab shows how many lines are left to buy.
      expect(find.descendant(of: find.byType(NavigationBar), matching: find.text('3')), findsOneWidget);
    });

    testWidgets('quantities change by steps and the smallest one removes the line', (tester) async {
      await tester.runAsync(() => shoppingList.addProduct(productId: 5, label: 'Café moulu 250g', quantity: 1));
      await pumpApp(tester);
      await tap(tester, 'Liste');

      await tester.tap(find.byTooltip('Augmenter la quantité'));
      await settle(tester);
      expect(await stored(tester), [('Café moulu 250g', 2.0, false)]);
      expect(find.textContaining('9,80'), findsNWidgets(2), reason: 'line total and list total');

      await tester.tap(find.byTooltip('Diminuer la quantité'));
      await settle(tester);
      expect(await stored(tester), [('Café moulu 250g', 1.0, false)]);

      await tester.tap(find.byTooltip('Retirer de la liste'));
      await settle(tester);
      expect(await stored(tester), isEmpty);
      expect(find.textContaining('Votre liste est vide.'), findsOneWidget);
    });

    testWidgets('checked lines move to the basket, which can be emptied', (tester) async {
      await tester.runAsync(() async {
        await shoppingList.addProduct(productId: 5, label: 'Café moulu 250g', quantity: 1);
        await shoppingList.addFreeLine('Pain');
      });
      await pumpApp(tester);
      await tap(tester, 'Liste');
      expect(find.textContaining('Dans le panier'), findsNothing);

      await tester.tap(find.bySemanticsLabel('Mettre Pain dans le panier'));
      await settle(tester);
      expect(find.text('Dans le panier (1)'), findsOneWidget);
      expect(await stored(tester), [('Café moulu 250g', 1.0, false), ('Pain', 1.0, true)]);

      await tester.tap(find.bySemanticsLabel('Remettre Pain à acheter'));
      await settle(tester);
      expect(find.textContaining('Dans le panier'), findsNothing);

      await tester.tap(find.bySemanticsLabel('Mettre Pain dans le panier'));
      await settle(tester);
      await tap(tester, 'Vider le panier');
      expect(await stored(tester), [('Café moulu 250g', 1.0, false)]);
    });

    testWidgets('a product page adds to the list too', (tester) async {
      await pumpApp(tester);
      await tap(tester, 'Catalogue');
      await tap(tester, 'Café moulu 250g');
      await tap(tester, 'Ajouter à la liste');
      await tap(tester, 'Ajouter à la liste');

      expect(await stored(tester), [('Café moulu 250g', 2.0, false)]);
    });

    testWidgets('logging out drops the list with the rest of the local data', (tester) async {
      await tester.runAsync(() => shoppingList.addFreeLine('Pain'));
      await pumpApp(tester);
      await tester.tap(find.byKey(const ValueKey('account-menu')));
      await settle(tester);
      await tap(tester, 'Se déconnecter');

      expect(await stored(tester), isEmpty);
    });
  });

  testWidgets('pointing at the price chart reads the price in force at that date', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PriceChart(
            changes: [
              PriceChange(since: DateTime(2026, 9, 1), price: 4.5, source: PriceSource.paid),
              PriceChange(since: DateTime(2026, 10, 1), price: 4.9, source: PriceSource.catalogue),
            ],
            until: DateTime(2026, 10, 31),
            uom: 'Units',
          ),
        ),
      ),
    );
    expect(find.text('Touchez la courbe pour lire un prix'), findsOneWidget);
    final chart = tester.getRect(find.byType(PriceChart));

    await tester.tapAt(Offset(chart.left + chart.width * 0.25, chart.center.dy));
    await tester.pump();
    expect(find.textContaining('4,50'), findsOneWidget);
    expect(find.textContaining('depuis le 1 sept.'), findsOneWidget);

    await tester.tapAt(Offset(chart.left + chart.width * 0.75, chart.center.dy));
    await tester.pump();
    expect(find.textContaining('4,90'), findsOneWidget);
    expect(find.textContaining('depuis le 1 oct.'), findsOneWidget);
  });

  testWidgets('a member without purchases is told why the list is empty', (tester) async {
    store
      ..server = _server
      ..token = 'tok';
    when(() => api.me(any())).thenAnswer((_) async => _member(consent: true));
    servePurchases(const []);

    await pumpApp(tester);

    expect(find.textContaining('Aucun achat trouvé'), findsOneWidget);
  });
}

void serveCatalogue(CoopApi api, List<Product> products) {
  when(() => api.productImageUrl(any(), any())).thenReturn('https://coop.example/image');
  when(() => api.authHeaders(any())).thenReturn(const {});
  when(
    () => api.products(any(), cursor: any(named: 'cursor')),
  ).thenAnswer((_) async => ProductPage(products: products, removedIds: const [], nextCursor: 'p1', hasMore: false));
}

Future<void> tap(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await settle(tester);
}

/// Lets the real database work and the interface catch up.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 400));
  }
}
