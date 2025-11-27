import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double toolbarHeight;

  const CustomAppBar({super.key, this.toolbarHeight = 80});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      toolbarHeight: toolbarHeight,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Logo
          Image.asset("assets/images/halulu_128x128.png", height: toolbarHeight * 0.8, width: toolbarHeight * 0.8, fit: BoxFit.contain),

          const SizedBox(width: 8),
          // Text Logo
          Text(
            "Halulu",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),

          Spacer(),
          // Settings Menu
          PopupMenuButton<String>(
            icon: Icon(Icons.settings, color: Colors.black, size: 80 * 0.5),
            onSelected: (value) {
              if (value == 'Theme') {
                debugPrint("Profile tapped");
              }
              // else if (value == 'logout') {
              //   print("Logout tapped");
              // }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'profile', child: Text('Profile')),
              const PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
