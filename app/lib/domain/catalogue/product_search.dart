import 'package:coop_assistant/domain/model/product.dart';

const _accents = {
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'á': 'a',
  'ã': 'a',
  'ç': 'c',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'î': 'i',
  'ï': 'i',
  'í': 'i',
  'ô': 'o',
  'ö': 'o',
  'ó': 'o',
  'õ': 'o',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ú': 'u',
  'ÿ': 'y',
  'ñ': 'n',
  'œ': 'oe',
  'æ': 'ae',
};

/// Lower-cased, accent-free form of [text]: "Pâtes complètes" → "pates completes".
String foldForSearch(String text) {
  final buffer = StringBuffer();
  for (final rune in text.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_accents[char] ?? char);
  }
  return buffer.toString();
}

/// Products of [category] (any when null) matching [query]: every word typed
/// must appear in the name, whatever the case and accents; a barcode matches
/// when typed in full.
List<Product> searchProducts(Iterable<Product> products, {String query = '', String? category}) {
  final words = foldForSearch(query).split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
  final barcode = query.trim();
  return [
    for (final product in products)
      if (category == null || product.category == category)
        if (words.isEmpty || product.barcode == barcode || words.every(foldForSearch(product.name).contains)) product,
  ];
}
