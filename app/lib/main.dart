import 'package:coop_assistant/data/auth/session_store.dart';
import 'package:coop_assistant/data/local/app_database.dart';
import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/data/repositories/product_repository.dart';
import 'package:coop_assistant/data/repositories/purchase_repository.dart';
import 'package:coop_assistant/data/repositories/shopping_list_repository.dart';
import 'package:coop_assistant/presentation/app.dart';
import 'package:coop_assistant/presentation/session/session_cubit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr');
  final api = CoopApi(
    Dio(BaseOptions(connectTimeout: const Duration(seconds: 15), receiveTimeout: const Duration(seconds: 30))),
  );
  final db = AppDatabase.onDevice();
  final purchases = PurchaseRepository(db, api);
  final products = ProductRepository(db, api);
  final shoppingList = ShoppingListRepository(db);
  final session = SessionCubit(
    api: api,
    store: const SecureSessionStore(),
    clearLocalData: () async {
      await purchases.clear();
      await products.clear();
      await shoppingList.clear();
    },
    deviceName: kIsWeb ? 'web' : defaultTargetPlatform.name,
  );
  runApp(
    CoopAssistantApp(session: session, api: api, purchases: purchases, products: products, shoppingList: shoppingList),
  );
  await session.restore();
}
