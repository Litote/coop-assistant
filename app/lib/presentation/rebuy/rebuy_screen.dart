import 'package:coop_assistant/domain/shopping/shopping_list.dart';
import 'package:coop_assistant/domain/suggestions/rebuy_suggestions.dart';
import 'package:coop_assistant/presentation/common/messages.dart';
import 'package:coop_assistant/presentation/rebuy/rebuy_cubit.dart';
import 'package:coop_assistant/presentation/shopping/add_to_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Products the member is about to run out of.
class RebuyView extends StatelessWidget {
  const RebuyView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<RebuyCubit, RebuyState>(
    builder: (context, state) => Column(
      children: [
        if (state.busy) const LinearProgressIndicator(),
        if (state.errorCode case final code?)
          MaterialBanner(
            content: Text(errorMessage(code)),
            actions: [
              TextButton(onPressed: () => context.read<RebuyCubit>().refresh(), child: const Text('Réessayer')),
            ],
          ),
        Expanded(child: _body(context, state)),
      ],
    ),
  );

  Widget _body(BuildContext context, RebuyState state) {
    if (state.consent == false) {
      return const _ConsentPrompt();
    }
    if (state.suggestions.isEmpty) {
      if (state.busy || (state.consent == null && !state.hasHistory)) {
        return const SizedBox.shrink();
      }
      return _Message(
        state.hasHistory
            ? "Rien à racheter pour l'instant."
            : "Aucun achat trouvé pour l'instant. Les suggestions apparaîtront après quelques passages en caisse.",
      );
    }
    return RefreshIndicator(
      onRefresh: () => context.read<RebuyCubit>().refresh(),
      child: Align(
        alignment: Alignment.topCenter,
        // Keeps the list readable on a wide (web, tablet) window.
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView.separated(
            itemCount: state.suggestions.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) => _SuggestionTile(state.suggestions[index]),
          ),
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile(this.suggestion);

  final RebuySuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final due = suggestion.status == RebuyStatus.due;
    final price = suggestion.lastUnitPrice;
    final habit =
        'Habituellement ${quantityLabel(suggestion.usualQuantity, suggestion.uom)} '
        'tous les ${suggestion.usualIntervalDays} jours';
    final lastPurchase =
        'Dernier achat le ${dayLabel(suggestion.lastPurchase)}'
        '${price == null ? '' : ' à ${unitPriceLabel(price, suggestion.uom)}'}';
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 4),
      title: Text(suggestion.productName),
      onTap: () => context.push('/products/${suggestion.productId}'),
      // The status sits under the name: beside it, it squeezed the text on a phone.
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: due ? colors.errorContainer : colors.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  due ? 'À racheter' : 'Bientôt',
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium!.copyWith(color: due ? colors.onErrorContainer : colors.onSecondaryContainer),
                ),
              ),
            ),
          ),
          Text(habit),
          Text(lastPurchase),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Ajouter ${suggestion.productName} à la liste',
            icon: const Icon(Icons.playlist_add),
            onPressed: () => addProductToShoppingList(
              context,
              productId: suggestion.productId,
              name: suggestion.productName,
              uom: suggestion.uom,
              quantity: suggestedQuantity(suggestion.usualQuantity, suggestion.uom),
            ),
          ),
          PopupMenuButton<void>(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: () => context.read<RebuyCubit>().hide(suggestion.productId),
                child: const Text('Ne plus proposer'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConsentPrompt extends StatelessWidget {
  const _ConsentPrompt();

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: ListView(
        padding: const EdgeInsets.all(24),
        shrinkWrap: true,
        children: [
          Text('Utiliser votre historique d\'achats ?', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Text(
            "Pour vous suggérer les produits à racheter, l'application a besoin de lire vos tickets de "
            'caisse des 24 derniers mois, enregistrés par votre coopérative.\n\n'
            'Ces données sont lues uniquement par vous, restent sur cet appareil et servent seulement à '
            'calculer vos suggestions. Vous pouvez désactiver cet accès à tout moment.',
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.read<RebuyCubit>().enablePurchaseHistory(),
            child: const Text("Activer l'historique d'achats"),
          ),
        ],
      ),
    ),
  );
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
