import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double toolbarHeight;
  final VoidCallback? onSettingsTap;

  const CustomAppBar({super.key, this.toolbarHeight = 80, this.onSettingsTap});

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

          const SizedBox(width: 8), // spacing between logo and text
          // Text Logo
          Text(
            "Halulu",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),

          Spacer(), // pushes the settings button to the right
          // Right Settings Button
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            iconSize: toolbarHeight * 0.5,
            onPressed: onSettingsTap ?? () {},
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
