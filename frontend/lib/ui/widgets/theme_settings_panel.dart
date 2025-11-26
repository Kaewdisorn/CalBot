import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class ThemeSettingsPanel extends ConsumerWidget {
  const ThemeSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    const presetColors = [Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.pink, Colors.teal, Colors.red];

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400), // limits the dialog height
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Mode
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: ListTile(
                title: const Text("Theme Mode", style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: DropdownButton<ThemeMode>(
                  value: theme.mode,
                  underline: const SizedBox(),
                  onChanged: (mode) {
                    if (mode != null) ref.read(themeProvider.notifier).setThemeMode(mode);
                  },
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text("System")),
                    DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Primary Color
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 1,
              child: ListTile(
                title: const Text("Primary Color", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("Tap to select your primary color"),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    for (final c in presetColors)
                      InkWell(
                        onTap: () => ref.read(themeProvider.notifier).setSeedColor(c),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.seedColor == c ? Theme.of(context).colorScheme.onPrimary : Colors.transparent, width: 3),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Reset Button
            Center(
              child: FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Reset to Default"),
                onPressed: () => ref.read(themeProvider.notifier).resetToDefault(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
