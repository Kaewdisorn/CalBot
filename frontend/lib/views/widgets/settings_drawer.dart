import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/widgets_controller/setting_controller.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final settingController = Get.find<SettingsController>();

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

            // ===== COLOR PALETTE MENU =====
            Obx(
              () => Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.color_lens),
                    title: Text("Color Theme"),
                    trailing: AnimatedRotation(
                      turns: settingController.themeExpanded.value ? 0.5 : 0,
                      duration: Duration(milliseconds: 200),
                      child: Icon(Icons.expand_more),
                    ),
                    onTap: settingController.toggleExpand,
                  ),

                  // ===== EXPANDABLE COLOR SECTION =====
                  SizeTransition(
                    sizeFactor: settingController.animation,
                    axisAlignment: -1,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40, bottom: 12, top: 6),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _colorDot(settingController, Colors.blue),
                          _colorDot(settingController, Colors.red),
                          _colorDot(settingController, Colors.green),
                          _colorDot(settingController, Colors.deepPurple),
                          _colorDot(settingController, Colors.orange),
                          _colorDot(settingController, Colors.pink),
                          _colorDot(settingController, Colors.teal),
                          _colorDot(settingController, Colors.cyan),
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
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: selected ? Border.all(color: Colors.white, width: 3) : null,
          ),
        ),
      );
    });
  }
}
