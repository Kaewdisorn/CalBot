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
            // ListTile(leading: Icon(Icons.person), title: Text("Profile"), onTap: () {}),

            // Color theme
            _colorPaletteMenu(settingController),

            // Divider(),

            // ListTile(leading: Icon(Icons.notifications), title: Text("Notifications"), onTap: () {}),

            // ListTile(leading: Icon(Icons.logout), title: Text("Logout"), onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _colorPaletteMenu(SettingsController settingController) {
    return Obx(
      () => Column(
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Color Theme'),
            trailing: AnimatedRotation(
              turns: settingController.themeExpanded.value ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.expand_more),
            ),
            onTap: settingController.toggleExpand,
          ),

          // Expand color section
          SizeTransition(
            sizeFactor: settingController.animation,
            axisAlignment: -1,
            child: Padding(
              padding: const EdgeInsets.only(left: 40, bottom: 12, top: 6, right: 5),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: SettingsController.palette.map((color) {
                  return Obx(() {
                    final selected = settingController.selectedColor.value == color;

                    return GestureDetector(
                      onTap: () => settingController.setColor(color),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                boxShadow: selected ? [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))] : null,
                              ),
                            ),
                            if (selected) const Icon(Icons.check, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
