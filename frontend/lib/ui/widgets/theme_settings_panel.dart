import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class ThemeSettingsPanel extends ConsumerWidget {
  const ThemeSettingsPanel({super.key});

  // ----------------------------
  // Section title helper
  // ----------------------------
  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  // ----------------------------
  // Static helper to show dialog
  // ----------------------------
  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360, maxHeight: 480),
          child: Stack(
            children: [
              const Padding(padding: EdgeInsets.all(16), child: ThemeSettingsPanel()),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop(), splashRadius: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // Build panel content
  // ----------------------------
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    const presetColors = [Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.pink, Colors.teal, Colors.red, Color(0xFFcab1cb)];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------
            // Theme Mode (updated for Flutter 3.38)
            // -------------------
            _sectionTitle(context, "Theme Mode"),
            RadioGroup<ThemeMode>(
              groupValue: theme.mode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeProvider.notifier).setThemeMode(mode);
                }
              },
              child: Column(
                children: ThemeMode.values.map((mode) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Radio<ThemeMode>(
                      value: mode, // just value, groupValue handled by RadioGroup
                    ),
                    title: Text(mode.name[0].toUpperCase() + mode.name.substring(1)),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // -------------------
            // Primary Color
            // -------------------
            _sectionTitle(context, "Primary Color"),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final c in presetColors)
                  GestureDetector(
                    onTap: () => ref.read(themeProvider.notifier).setSeedColor(c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.seedColor.toARGB32() == c.toARGB32() ? Theme.of(context).colorScheme.onPrimary : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 32),

            // -------------------
            // Reset Button
            // -------------------
            Center(
              child: FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Reset"),
                onPressed: () => ref.read(themeProvider.notifier).resetToDefault(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
