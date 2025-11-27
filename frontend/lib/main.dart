import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/theme_settings.dart';
import 'providers/theme_provider.dart';
import 'ui/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ThemeSettingsAdapter());

  // IMPORTANT: open the box BEFORE ProviderScope
  await Hive.openBox<ThemeSettings>('settings');

  runApp(const ProviderScope(child: CalBotApp()));
}

class CalBotApp extends ConsumerWidget {
  const CalBotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Halulu',
      debugShowCheckedModeBanner: false,
      themeMode: theme.mode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: theme.seedColor,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(backgroundColor: theme.seedColor, foregroundColor: Colors.white),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: theme.seedColor,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(backgroundColor: theme.seedColor, foregroundColor: Colors.white),
      ),
      home: const HomePage(),
    );
  }
}
