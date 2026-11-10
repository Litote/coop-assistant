import 'package:coop_assistant/data/repositories/shopping_list_repository.dart';
import 'package:coop_assistant/presentation/common/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Puts a catalogue product on the shopping list and says so.
Future<void> addProductToShoppingList(
  BuildContext context, {
  required int productId,
  required String name,
  required String uom,
  required double quantity,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  await context.read<ShoppingListRepository>().addProduct(productId: productId, label: name, quantity: quantity);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('${quantityLabel(quantity, uom)} × $name ajouté à la liste'),
        duration: const Duration(seconds: 2),
      ),
    );
}
