import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController with GetSingleTickerProviderStateMixin {
  // Controls the expand/collapse state
  var themeExpanded = false.obs;

  // Animation controller for smooth expanding
  late AnimationController expandController;
  late Animation<double> animation;

  // Custom color palette (selected swatch)
  var selectedColor = Colors.blue.obs;

  // Storage box
  late final GetStorage _box;

  // Known palette used across the app (keeps mapping simple)
  // Exposed publicly so UI can reuse the exact same palette and avoid mistakes
  static const List<MaterialColor> palette = [Colors.blue, Colors.red, Colors.green, Colors.deepPurple, Colors.orange, Colors.pink, Colors.teal, Colors.cyan];

  @override
  void onInit() {
    super.onInit();

    expandController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);

    animation = CurvedAnimation(parent: expandController, curve: Curves.easeInOut);

    _box = GetStorage();

    // Load saved color seed
    final savedColorValue = _box.read('colorSeed') as int?;
    if (savedColorValue != null) {
      final matched = palette.firstWhere((c) => c.toARGB32() == savedColorValue, orElse: () => Colors.blue);
      selectedColor.value = matched;
    }
  }

  void toggleExpand() {
    themeExpanded.value = !themeExpanded.value;

    if (themeExpanded.value) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  void setColor(MaterialColor color) {
    selectedColor.value = color;

    // Persist seed and update theme (preserve current brightness setting if present)
    _box.write('colorSeed', color.toARGB32());
    // Always apply light theme with the selected color
    final theme = ThemeData(colorSchemeSeed: color, brightness: Brightness.light);
    Get.changeTheme(theme);
  }
}
