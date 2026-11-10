import 'package:coop_assistant/domain/catalogue/product_search.dart';
import 'package:coop_assistant/domain/model/product.dart';
import 'package:flutter_test/flutter_test.dart';

Product _product(int id, String name, {String category = 'Épicerie', String? barcode}) =>
    Product(id: id, name: name, category: category, uom: 'Units', priceIncl: 1, barcode: barcode);

final _products = [
  _product(1, 'Café moulu 250g', barcode: '3760000000017'),
  _product(2, 'Pâtes complètes 500g'),
  _product(3, 'Œufs x6', category: 'Frais'),
  _product(4, 'Café en grains 1kg'),
];

List<int> _ids(List<Product> products) => [for (final product in products) product.id];

void main() {
  test('an empty query lists everything', () {
    expect(_ids(searchProducts(_products)), [1, 2, 3, 4]);
    expect(_ids(searchProducts(_products, query: '   ')), [1, 2, 3, 4]);
  });

  test('case and accents are ignored', () {
    expect(_ids(searchProducts(_products, query: 'cafe')), [1, 4]);
    expect(_ids(searchProducts(_products, query: 'PATES')), [2]);
    expect(_ids(searchProducts(_products, query: 'oeufs')), [3]);
  });

  test('every word must match, in any order', () {
    expect(_ids(searchProducts(_products, query: 'grains café')), [4]);
    expect(searchProducts(_products, query: 'café thé'), isEmpty);
  });

  test('a full barcode finds its product', () {
    expect(_ids(searchProducts(_products, query: '3760000000017')), [1]);
    expect(searchProducts(_products, query: '376000'), isEmpty);
  });

  test('the category narrows the search', () {
    expect(_ids(searchProducts(_products, category: 'Frais')), [3]);
    expect(searchProducts(_products, query: 'café', category: 'Frais'), isEmpty);
  });
}
