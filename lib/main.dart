import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import 'data/isar_service.dart';
import 'models/settings.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isar = await openIsar();
  final settings = await isar.settings.get(0);
  final themeMode =
      settings?.themeMode == 'dark' ? ThemeMode.dark : ThemeMode.light;
  runApp(ExpenseApp(isar: isar, initialThemeMode: themeMode));
}

class ExpenseApp extends StatefulWidget {
  final Isar isar;
  final ThemeMode initialThemeMode;

  const ExpenseApp({
    super.key,
    required this.isar,
    required this.initialThemeMode,
  });

  @override
  State<ExpenseApp> createState() => _ExpenseAppState();
}

class _ExpenseAppState extends State<ExpenseApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  Future<void> _toggleTheme() async {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
    await widget.isar.writeTxn(() async {
      await widget.isar.settings.put(
        Settings()
          ..id = 0
          ..themeMode = _themeMode == ThemeMode.dark ? 'dark' : 'light',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expenses',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: HomeScreen(
        isar: widget.isar,
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
