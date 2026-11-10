import 'package:coop_assistant/data/network/coop_api.dart';
import 'package:coop_assistant/domain/model/coop_server.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A product's picture, or a neutral placeholder when it has none.
class ProductImage extends StatelessWidget {
  const ProductImage({required this.productId, required this.hasImage, required this.size, super.key});

  final int productId;

  /// Nothing is fetched for a product without picture.
  final bool hasImage;
  final double size;

  @override
  Widget build(BuildContext context) {
    final api = context.read<CoopApi>();
    final session = context.read<Session>();
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.shopping_basket_outlined, size: size / 2, color: Theme.of(context).colorScheme.outline),
    );
    if (!hasImage) {
      return placeholder;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        api.productImageUrl(session, productId),
        headers: api.authHeaders(session),
        width: size,
        height: size,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        errorBuilder: (context, error, stackTrace) => placeholder,
        loadingBuilder: (context, child, progress) => progress == null ? child : placeholder,
      ),
    );
  }
}
