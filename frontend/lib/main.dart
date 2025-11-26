import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/pages/home_page.dart';

void main() {
  runApp(const ProviderScope(child: CalBotApp()));
}

class CalBotApp extends StatelessWidget {
  const CalBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'CalBot Web', debugShowCheckedModeBanner: false, home: HomePage());
  }
}
