import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/item.dart';
import 'edit_item_screen.dart';
import 'settings_screen.dart';
import '../theme_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Item> _inventoryBox;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _inventoryBox = Hive.box<Item>('inventory');
  }

  Future<void> _addNewItem() async {
    final newItem = await Navigator.push<Item>(
      context,
      MaterialPageRoute(builder: (context) => const EditItemScreen()),
    );
    if (newItem != null) {
      await _inventoryBox.put(newItem.id, newItem);
      setState(() {});
    }
  }

  Future<void> _editItem(String id) async {
    final existingItem = _inventoryBox.get(id);
    if (existingItem == null) return;

    final updatedItem = await Navigator.push<Item>(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemScreen(item: existingItem),
      ),
    );
    if (updatedItem != null) {
      await _inventoryBox.put(id, updatedItem);
      setState(() {});
    }
  }

  Future<void> _deleteItem(String id) async {
    await _inventoryBox.delete(id);
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final allItems = _inventoryBox.values.toList();

    // Get unique categories
    final List<String> categories =
        allItems.map((item) => item.category).toSet().toList()..sort();

    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NVNTRY'),
          bottom: TabBar(
            isScrollable: true,
            tabs: categories.map((cat) => Tab(text: cat)).toList(),
          ),
        ),
        body: TabBarView(
          children:
              categories.map((category) {
                final items =
                    allItems
                        .where((item) => item.category == category)
                        .toList();

                if (items.isEmpty) {
                  return const Center(
                    child: Text('No items in this category.'),
                  );
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _deleteItem(item.id),
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text('Qty: ${item.quantity}'),
                        onTap: () => _editItem(item.id),
                      ),
                    );
                  },
                );
              }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addNewItem,
          tooltip: 'Add Item',
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              SettingsScreen(themeController: themeController),
                    ),
                  );
                  setState(() {});
                },
              ),
              const SizedBox(width: 48),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
