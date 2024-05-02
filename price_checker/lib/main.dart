import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:price_checker/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:price_checker/screens/tab_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool _loggedIn = prefs.getBool('loggedIn') ?? false;
  bool _isDarkMode = prefs.getBool('isDarkMode') ?? false;

  runApp(
    ProviderScope(
      child: MyApp(
        showHome: _loggedIn,
        isDarkMode: ValueNotifier<bool>(_isDarkMode),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showHome;
  final ValueNotifier<bool> isDarkMode;

  MyApp({required this.showHome, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          theme: isDark ? ThemeData.dark() : ThemeData.light(),
          home: showHome ? TabScreen() : MainScreen(),
        );
      },
    );
  }
}
