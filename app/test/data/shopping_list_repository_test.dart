import 'package:coop_assistant/data/local/app_database.dart';
import 'package:coop_assistant/data/repositories/shopping_list_repository.dart';
import 'package:coop_assistant/domain/shopping/shopping_list.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ShoppingListRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ShoppingListRepository(db);
  });

  tearDown(() => db.close());

  Future<List<ShoppingItem>> items() => repository.watchItems().first;

  Future<List<(String, int?, double, bool)>> lines() async => [
    for (final item in await items()) (item.label, item.productId, item.quantity, item.checked),
  ];

  test('products and free lines are listed in the order they were added', () async {
    await repository.addProduct(productId: 5, label: 'Café', quantity: 2);
    await repository.addFreeLine('  Pain  ');
    await repository.addProduct(productId: 7, label: 'Carottes', quantity: 0.8);

    expect(await lines(), [('Café', 5, 2.0, false), ('Pain', null, 1.0, false), ('Carottes', 7, 0.8, false)]);
  });

  test('adding a product already to buy increases its quantity', () async {
    await repository.addProduct(productId: 7, label: 'Carottes', quantity: 0.1);
    await repository.addProduct(productId: 7, label: 'Carottes', quantity: 0.2);

    expect(await lines(), [('Carottes', 7, 0.3, false)]);
  });

  test('a product already in the basket gets a new line', () async {
    await repository.addProduct(productId: 5, label: 'Café', quantity: 1);
    await repository.setChecked((await items()).single.id, checked: true);
    await repository.addProduct(productId: 5, label: 'Café', quantity: 1);

    expect(await lines(), [('Café', 5, 1.0, true), ('Café', 5, 1.0, false)]);
  });

  test('the same free text, whatever its case, is counted once more; blank text is ignored', () async {
    await repository.addFreeLine('Pain');
    await repository.addFreeLine('pain ');
    await repository.addFreeLine('   ');

    expect(await lines(), [('Pain', null, 2.0, false)]);
  });

  test('a line can be checked, unchecked, resized and removed', () async {
    await repository.addFreeLine('Pain');
    await repository.addFreeLine('Sel');
    final [bread, salt] = await items();

    await repository.setChecked(bread.id, checked: true);
    await repository.setQuantity(salt.id, 3);
    expect(await lines(), [('Pain', null, 1.0, true), ('Sel', null, 3.0, false)]);

    await repository.setChecked(bread.id, checked: false);
    await repository.remove(salt.id);
    expect(await lines(), [('Pain', null, 1.0, false)]);
  });

  test('emptying the basket keeps what is still to buy', () async {
    await repository.addFreeLine('Pain');
    await repository.addFreeLine('Sel');
    await repository.setChecked((await items()).first.id, checked: true);

    await repository.removeChecked();
    expect(await lines(), [('Sel', null, 1.0, false)]);

    await repository.clear();
    expect(await lines(), isEmpty);
  });

  test('a database of the previous version gains the shopping list', () async {
    final upgraded = AppDatabase(
      NativeDatabase.memory(
        setup: (raw) => raw
          ..execute('CREATE TABLE sync_cursors (feed TEXT NOT NULL PRIMARY KEY, cursor TEXT NOT NULL)')
          ..execute('PRAGMA user_version = 2'),
      ),
    );
    addTearDown(upgraded.close);
    final upgradedRepository = ShoppingListRepository(upgraded);

    await upgradedRepository.addFreeLine('Pain');

    expect(await upgradedRepository.watchItems().first, hasLength(1));
  });
}
