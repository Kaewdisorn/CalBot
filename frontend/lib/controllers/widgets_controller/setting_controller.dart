import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController with GetSingleTickerProviderStateMixin {
  // Controls the expand/collapse state
  var themeExpanded = false.obs;

  // Animation controller for smooth expanding
  late AnimationController expandController;
  late Animation<double> animation;

  // Selected color (can be from palette or custom)
  var selectedColor = Rx<Color>(Colors.blue);

  // Custom color hex input
  final customColorController = TextEditingController();
  var customColorError = RxnString(null);

  // Storage box
  late final GetStorage _box;

  // Known palette used across the app
  static const List<Color> palette = [Colors.indigo, Colors.teal, Colors.deepOrange, Colors.purple, Colors.amber, Colors.pink];

  @override
  void onInit() {
    super.onInit();

    expandController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);

    animation = CurvedAnimation(parent: expandController, curve: Curves.easeInOut);

    _box = GetStorage();

    // Load saved color
    final savedColorValue = _box.read('colorSeed') as int?;
    if (savedColorValue != null) {
      selectedColor.value = Color(savedColorValue);
      // Set hex in text field
      customColorController.text = _colorToHex(Color(savedColorValue));
    }
  }

  @override
  void onClose() {
    customColorController.dispose();
    expandController.dispose();
    super.onClose();
  }

  void toggleExpand() {
    themeExpanded.value = !themeExpanded.value;

    if (themeExpanded.value) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  void setColor(Color color) {
    selectedColor.value = color;
    customColorController.text = _colorToHex(color);
    customColorError.value = null;

    // Persist and update theme
    _box.write('colorSeed', color.toARGB32());
    final theme = ThemeData(colorSchemeSeed: color, brightness: Brightness.light);
    Get.changeTheme(theme);
  }

  /// Parse hex color string and apply it
  void applyCustomColor(String hexString) {
    final color = _parseHexColor(hexString);
    if (color != null) {
      customColorError.value = null;
      setColor(color);
    } else {
      customColorError.value = 'Invalid hex code';
    }
  }

  /// Convert Color to hex string (without alpha)
  String _colorToHex(Color color) {
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// Parse hex string to Color
  Color? _parseHexColor(String hexString) {
    try {
      String hex = hexString.trim();
      // Remove # if present
      if (hex.startsWith('#')) {
        hex = hex.substring(1);
      }
      // Remove 0x if present
      if (hex.toLowerCase().startsWith('0x')) {
        hex = hex.substring(2);
      }
      // Validate length
      if (hex.length != 6 && hex.length != 8) {
        return null;
      }
      // Add alpha if not present
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      final intValue = int.tryParse(hex, radix: 16);
      if (intValue == null) return null;
      return Color(intValue);
    } catch (_) {
      return null;
    }
  }

  /// Check if a color is selected (matches with tolerance for custom colors)
  bool isColorSelected(Color color) {
    return selectedColor.value.toARGB32() == color.toARGB32();
  }
}
