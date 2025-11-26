import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_provider.dart';
import 'ui/pages/home_page.dart';

void main() {
  runApp(const ProviderScope(child: CalBotApp()));
}

class CalBotApp extends ConsumerWidget {
  const CalBotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeProvider);

    final seedColor = themeSettings.seedColor ?? Colors.blue; // fallback color

    return MaterialApp(
      title: 'Halulu',
      debugShowCheckedModeBanner: false,
      themeMode: themeSettings.mode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seedColor,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(backgroundColor: seedColor, foregroundColor: Colors.white),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seedColor,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(backgroundColor: seedColor, foregroundColor: Colors.white),
      ),
      home: const HomePage(),
    );
  }
}
