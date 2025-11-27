import 'package:flutter/material.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text("Settings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),

            Divider(),

            // Menu Items
            ListTile(leading: Icon(Icons.person), title: Text("Profile"), onTap: () {}),

            ListTile(leading: Icon(Icons.color_lens), title: Text("Theme"), onTap: () {}),

            ListTile(leading: Icon(Icons.notifications), title: Text("Notifications"), onTap: () {}),

            ListTile(leading: Icon(Icons.logout), title: Text("Logout"), onTap: () {}),
          ],
        ),
      ),
    );
  }
}
