import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme_controller.dart';
import '../models/item.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeController themeController;
  const SettingsScreen({super.key, required this.themeController});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeController.isDark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDark,
            onChanged: (value) {
              widget.themeController.toggleDarkMode(value);
              setState(() {}); // rebuild to update toggle state
            },
          ),
          ListTile(
            title: const Text('Clear All Items (WRAP THIS LATER)'),
            leading: const Icon(Icons.delete_forever),
            onTap: () async {
              final box = Hive.box<Item>('inventory');
              await box.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All Items Deleted.')),
              );
            },
          ),
          const Divider(),
          const ListTile(title: Text('More settings coming soon...')),
        ],
      ),
    );
  }
}
