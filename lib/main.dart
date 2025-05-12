import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/item.dart';
import 'screens/home_screen.dart';
import 'theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ItemAdapter());
  await Hive.openBox<Item>('inventory');
  runApp(const NvntryApp());
}

class NvntryApp extends StatelessWidget {
  const NvntryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'NVNTRY',
          themeMode: mode,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}
