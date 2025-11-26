import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class ThemeSettingsPanel extends ConsumerWidget {
  const ThemeSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    const presetColors = [Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.pink, Colors.teal, Colors.red];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Theme Mode", style: TextStyle(fontSize: 16)),
        DropdownButton<ThemeMode>(
          value: theme.mode,
          onChanged: (mode) {
            if (mode != null) {
              ref.read(themeProvider.notifier).setThemeMode(mode);
            }
          },
          items: const [
            DropdownMenuItem(value: ThemeMode.system, child: Text("System")),
            DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
            DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
          ],
        ),
        const SizedBox(height: 20),
        const Text("Primary Color", style: TextStyle(fontSize: 16)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in presetColors)
              GestureDetector(
                onTap: () => ref.read(themeProvider.notifier).setSeedColor(c),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.seedColor == c ? Colors.white : Colors.transparent, width: 3),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
