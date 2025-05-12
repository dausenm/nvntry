import 'package:flutter/material.dart';
import '../models/item.dart';
import 'package:hive_flutter/hive_flutter.dart';

class EditItemScreen extends StatefulWidget {
  final Item? item;

  const EditItemScreen({super.key, this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late int _quantity;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    final box = Hive.box<Item>('inventory');
    _name = widget.item?.name ?? '';
    _categories =
        box.values.map((item) => item.category).toSet().toList()..sort();
    _categories.add('Create new...');
    _category =
        widget.item?.category ??
        (_categories.isNotEmpty ? _categories.first : '');
    _quantity = widget.item?.quantity ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Item' : 'Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Item Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              DropdownButtonFormField<String>(
                value: _categories.contains(_category) ? _category : null,
                decoration: const InputDecoration(labelText: 'Category'),
                items:
                    _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value == 'Create new...') {
                    _showCreateCategoryDialog();
                  } else {
                    setState(() {
                      _category = value!;
                    });
                  }
                },
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter a category'
                            : null,
                onSaved: (value) => _category = value!,
              ),

              TextFormField(
                initialValue: _quantity.toString(),
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final n = int.tryParse(value ?? '');
                  if (n == null || n < 1) return 'Enter a valid quantity';
                  return null;
                },
                onSaved: (value) => _quantity = int.parse(value!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final result = Item(
                      id: widget.item?.id ?? DateTime.now().toString(),
                      name: _name,
                      category: _category,
                      quantity: _quantity,
                    );

                    Navigator.pop(context, result);
                  }
                },
                child: Text(isEditing ? 'Save Changes' : 'Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateCategoryDialog() async {
    String newCategory = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create new category'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter category name'),
            onChanged: (value) {
              newCategory = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newCategory.isNotEmpty) {
                  setState(() {
                    _category = newCategory;
                    _categories.insert(_categories.length - 1, newCategory);
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
