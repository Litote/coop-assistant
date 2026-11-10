import 'package:coop_assistant/domain/shopping/shopping_list.dart';
import 'package:coop_assistant/presentation/catalogue/catalogue_view.dart';
import 'package:coop_assistant/presentation/rebuy/rebuy_screen.dart';
import 'package:coop_assistant/presentation/session/session_cubit.dart';
import 'package:coop_assistant/presentation/shopping/shopping_list_cubit.dart';
import 'package:coop_assistant/presentation/shopping/shopping_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The signed-in member's home: one tab per feature.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _titles = ['À racheter', 'Ma liste', 'Catalogue'];
  var _tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_titles[_tab]),
      actions: [
        PopupMenuButton<void>(
          key: const ValueKey('account-menu'),
          itemBuilder: (context) => [
            PopupMenuItem(onTap: () => context.read<SessionCubit>().logout(), child: const Text('Se déconnecter')),
          ],
        ),
      ],
    ),
    // Both tabs stay alive: switching back keeps the search and the scroll position.
    body: IndexedStack(index: _tab, children: const [RebuyView(), ShoppingListTab(), CatalogueView()]),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (tab) => setState(() => _tab = tab),
      destinations: [
        const NavigationDestination(icon: Icon(Icons.replay), label: 'À racheter'),
        NavigationDestination(
          // How many lines are still to buy.
          icon: BlocBuilder<ShoppingListCubit, ShoppingListView>(
            builder: (context, list) => Badge(
              isLabelVisible: list.toBuy.isNotEmpty,
              label: Text('${list.toBuy.length}'),
              child: const Icon(Icons.checklist),
            ),
          ),
          label: 'Liste',
        ),
        const NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Catalogue'),
      ],
    ),
  );
}
