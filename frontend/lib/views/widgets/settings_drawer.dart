import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/widgets_controller/setting_controller.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(SettingsController());

    return Drawer(
      width: 280,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Settings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            Divider(),

            // ===== PROFILE =====
            ListTile(leading: Icon(Icons.person), title: Text("Profile"), onTap: () {}),

            // ===== THEME =====
            Obx(
              () => Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.color_lens),
                    title: Text("Theme"),
                    trailing: AnimatedRotation(turns: c.themeExpanded.value ? 0.5 : 0, duration: Duration(milliseconds: 200), child: Icon(Icons.expand_more)),
                    onTap: c.toggleExpand,
                  ),

                  // ===== Animated Submenu =====
                  SizeTransition(
                    sizeFactor: c.animation,
                    axisAlignment: -1.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40.0),
                      child: Column(
                        children: [
                          // LIGHT
                          ListTile(
                            leading: Icon(Icons.light_mode, color: Colors.orange),
                            title: Text("Light"),
                            onTap: () => c.setTheme(ThemeMode.light),
                          ),

                          // DARK
                          ListTile(
                            leading: Icon(Icons.dark_mode, color: Colors.blueGrey),
                            title: Text("Dark"),
                            onTap: () => c.setTheme(ThemeMode.dark),
                          ),

                          // SYSTEM
                          ListTile(
                            leading: Icon(Icons.brightness_auto, color: Colors.green),
                            title: Text("System Default"),
                            onTap: () => c.setTheme(ThemeMode.system),
                          ),

                          Divider(),

                          // ===== CUSTOM COLOR PALETTE =====
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Color Palette", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                          ),

                          SizedBox(height: 10),

                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _colorDot(c, Colors.blue),
                              _colorDot(c, Colors.red),
                              _colorDot(c, Colors.green),
                              _colorDot(c, Colors.deepPurple),
                              _colorDot(c, Colors.orange),
                              _colorDot(c, Colors.pink),
                            ],
                          ),

                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(),

            ListTile(leading: Icon(Icons.notifications), title: Text("Notifications"), onTap: () {}),

            ListTile(leading: Icon(Icons.logout), title: Text("Logout"), onTap: () {}),
          ],
        ),
      ),
    );
  }

  // ===== COLOR SELECTOR DOT WIDGET =====
  Widget _colorDot(SettingsController c, MaterialColor color) {
    return Obx(() {
      final selected = c.selectedColor.value == color;

      return GestureDetector(
        onTap: () => c.setColor(color),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: selected ? 32 : 26,
          height: selected ? 32 : 26,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: selected ? Border.all(color: Colors.white, width: 3) : null,
            boxShadow: [if (selected) BoxShadow(color: color.withOpacity(0.7), blurRadius: 10, spreadRadius: 2)],
          ),
        ),
      );
    });
  }
}
