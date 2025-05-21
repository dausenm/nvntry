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

    if (_inventoryBox.isEmpty) {
      _addTestItems();
    }
  }

  void _addTestItems() {
    final testItems = [
      Item(id: '1', name: 'Milk', category: 'Fridge', quantity: 1),
      Item(id: '2', name: 'Eggs', category: 'Fridge', quantity: 12),
      Item(id: '3', name: 'Socks', category: 'Closet', quantity: 5),
      Item(id: '4', name: 'Notebook', category: 'Desk', quantity: 3),
      Item(id: '5', name: 'Umbrella', category: 'Car', quantity: 1),
      Item(
        id: '6',
        name: 'Limp Bizkit Significant Other CD',
        category: 'Car',
        quantity: 1,
      ),
      Item(
        id: '7',
        name: 'Pilot Precise V5 RT',
        category: 'Desk',
        quantity: 13,
      ),
      Item(id: '8', name: 'Vans Sk8 Hi', category: 'Closet', quantity: 1),
      Item(id: '9', name: 'Ketchup', category: 'Fridge', quantity: 1),
      Item(id: '10', name: 'Kraft Singles', category: 'Fridge', quantity: 21),
      Item(
        id: '11',
        name: 'White Carhartt T-Shirt',
        category: 'Closet',
        quantity: 1,
      ),
      Item(
        id: '12',
        name: 'Black Carhartt T-Shirt',
        category: 'Closet',
        quantity: 2,
      ),
    ];

    for (var item in testItems) {
      _inventoryBox.put(item.id, item);
    }
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search items',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children:
                    categories.map((category) {
                      final items =
                          allItems
                              .where(
                                (item) =>
                                    item.category == category &&
                                    item.name.toLowerCase().contains(
                                      _searchQuery.toLowerCase(),
                                    ),
                              )
                              .toList();

                      if (items.isEmpty) {
                        return const Center(
                          child: Text('No matching items in this category.'),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
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
            ),
          ],
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
