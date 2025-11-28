import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController with GetSingleTickerProviderStateMixin {
  // Controls the expand/collapse state
  var themeExpanded = false.obs;

  // Animation controller for smooth expanding
  late AnimationController expandController;
  late Animation<double> animation;

  // Selected theme mode
  var selectedTheme = ThemeMode.system.obs;

  // Custom color palette (selected swatch)
  var selectedColor = Colors.blue.obs;

  @override
  void onInit() {
    super.onInit();

    expandController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);

    animation = CurvedAnimation(parent: expandController, curve: Curves.easeInOut);
  }

  void toggleExpand() {
    themeExpanded.value = !themeExpanded.value;

    if (themeExpanded.value) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  // Apply theme
  void setTheme(ThemeMode mode) {
    selectedTheme.value = mode;
    Get.changeThemeMode(mode);
  }

  // Apply custom color
  void setColor(MaterialColor color) {
    selectedColor.value = color;

    final theme = ThemeData(colorSchemeSeed: color, brightness: selectedTheme.value == ThemeMode.dark ? Brightness.dark : Brightness.light);

    Get.changeTheme(theme);
  }
}
