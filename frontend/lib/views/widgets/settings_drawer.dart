import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/widgets_controller/setting_controller.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final settingController = Get.find<SettingsController>();
    final homeController = Get.find<HomeController>();

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

            // ===== VIEW MODE =====
            _agendaViewToggle(homeController),

            // ===== PROFILE =====
            // ListTile(leading: Icon(Icons.person), title: Text("Profile"), onTap: () {}),

            // Color theme
            _colorPaletteMenu(settingController),

            // Divider(),

            // ListTile(leading: Icon(Icons.notifications), title: Text("Notifications"), onTap: () {}),

            // ListTile(leading: Icon(Icons.logout), title: Text("Logout"), onTap: () {});
          ],
        ),
      ),
    );
  }

  Widget _agendaViewToggle(HomeController homeController) {
    return Obx(
      () => ListTile(
        leading: Icon(
          homeController.isAgendaView.value ? Icons.view_agenda : Icons.calendar_view_month,
          color: homeController.isAgendaView.value ? Colors.blue : null,
        ),
        title: const Text('Agenda View'),
        subtitle: Text(
          homeController.isAgendaView.value ? 'Enabled' : 'Disabled',
          style: TextStyle(color: homeController.isAgendaView.value ? Colors.blue : Colors.grey, fontSize: 12),
        ),
        trailing: Switch(value: homeController.isAgendaView.value, onChanged: (val) => homeController.isAgendaView.value = val, activeThumbColor: Colors.blue),
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
              padding: const EdgeInsets.only(left: 16, bottom: 12, top: 6, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Color palette
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: SettingsController.palette.map((color) {
                      return Obx(() {
                        final selected = settingController.isColorSelected(color);

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
                                    boxShadow: selected ? [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))] : null,
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

                  const SizedBox(height: 16),

                  // Custom color input
                  Row(
                    children: [
                      // Color preview
                      Obx(
                        () => Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: settingController.selectedColor.value,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Hex input field
                      Expanded(
                        child: TextField(
                          controller: settingController.customColorController,
                          decoration: InputDecoration(
                            labelText: 'Hex Code',
                            hintText: '#FF5733',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            errorText: settingController.customColorError.value,
                            errorStyle: const TextStyle(fontSize: 11),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.check, size: 20),
                              onPressed: () => settingController.applyCustomColor(settingController.customColorController.text),
                              tooltip: 'Apply color',
                            ),
                          ),
                          style: const TextStyle(fontSize: 14),
                          onSubmitted: settingController.applyCustomColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
