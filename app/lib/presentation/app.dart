import 'dart:async';

import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/data/repositories/product_repository.dart';
import 'package:coop_assistant/data/repositories/purchase_repository.dart';
import 'package:coop_assistant/data/repositories/shopping_list_repository.dart';
import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:coop_assistant/presentation/auth/login_screen.dart';
import 'package:coop_assistant/presentation/catalogue/catalogue_cubit.dart';
import 'package:coop_assistant/presentation/home/home_screen.dart';
import 'package:coop_assistant/presentation/product/product_cubit.dart';
import 'package:coop_assistant/presentation/product/product_screen.dart';
import 'package:coop_assistant/presentation/rebuy/rebuy_cubit.dart';
import 'package:coop_assistant/presentation/server/server_screen.dart';
import 'package:coop_assistant/presentation/session/session_cubit.dart';
import 'package:coop_assistant/presentation/shopping/shopping_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

class CoopAssistantApp extends StatefulWidget {
  const CoopAssistantApp({
    required this.session,
    required this.api,
    required this.purchases,
    required this.products,
    required this.shoppingList,
    super.key,
  });

  final SessionCubit session;
  final CoopApi api;
  final PurchaseRepository purchases;
  final ProductRepository products;
  final ShoppingListRepository shoppingList;

  @override
  State<CoopAssistantApp> createState() => _CoopAssistantAppState();
}

class _CoopAssistantAppState extends State<CoopAssistantApp> {
  static const _signedOutLocations = {'/loading', '/server', '/login'};

  late final _sessionChanges = _StreamListenable(widget.session.stream);
  late final _router = GoRouter(
    initialLocation: '/',
    refreshListenable: _sessionChanges,
    // The session alone decides which screens are reachable.
    redirect: (context, state) => switch (widget.session.state) {
      SessionLoading() => '/loading',
      SessionNoServer() => '/server',
      SessionLoggedOut() => '/login',
      SessionLoggedIn() => _signedOutLocations.contains(state.matchedLocation) ? '/' : null,
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(path: '/server', builder: (context, state) => const ServerScreen()),
      GoRoute(
        path: '/login',
        builder: (context, state) => switch (widget.session.state) {
          SessionLoggedOut(:final server) => LoginScreen(server: server),
          _ => const SizedBox.shrink(),
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => _signedIn(
          (session) => MultiBlocProvider(
            key: ValueKey(session.token),
            providers: [
              BlocProvider(
                create: (context) => RebuyCubit(
                  session: session,
                  api: widget.api,
                  purchases: widget.purchases,
                  onUnauthorized: widget.session.expire,
                )..refresh(),
              ),
              BlocProvider(
                create: (context) =>
                    CatalogueCubit(session: session, products: widget.products, onUnauthorized: widget.session.expire)
                      ..refresh(),
              ),
              BlocProvider(
                create: (context) => ShoppingListCubit(shoppingList: widget.shoppingList, products: widget.products),
              ),
            ],
            child: const HomeScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/products/:id',
        redirect: (context, state) => int.tryParse(state.pathParameters['id']!) == null ? '/' : null,
        builder: (context, state) {
          final productId = int.parse(state.pathParameters['id']!);
          return _signedIn(
            (session) => BlocProvider(
              create: (context) =>
                  ProductCubit(productId: productId, products: widget.products, purchases: widget.purchases),
              child: ProductScreen(productId: productId),
            ),
          );
        },
      ),
    ],
  );

  /// A screen of the signed-in member, with their [Session] in scope.
  Widget _signedIn(Widget Function(Session session) builder) => switch (widget.session.state) {
    SessionLoggedIn(:final session) => RepositoryProvider.value(value: session, child: builder(session)),
    _ => const SizedBox.shrink(),
  };

  @override
  void dispose() {
    _router.dispose();
    _sessionChanges.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: widget.api),
      RepositoryProvider.value(value: widget.shoppingList),
    ],
    child: BlocProvider.value(
      value: widget.session,
      child: MaterialApp.router(
        title: 'Coop Assistant',
        theme: ThemeData(colorSchemeSeed: const Color(0xFF2E7D32)),
        darkTheme: ThemeData(colorSchemeSeed: const Color(0xFF2E7D32), brightness: Brightness.dark),
        locale: const Locale('fr'),
        supportedLocales: const [Locale('fr')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        routerConfig: _router,
      ),
    ),
  );
}

class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
