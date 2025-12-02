import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double toolbarHeight;
  final String titleText;
  final String logoAsset;
  final Color? appbarColor;

  const CustomAppBar({super.key, required this.toolbarHeight, required this.titleText, required this.logoAsset, this.appbarColor});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: appbarColor?.withAlpha(50) ?? Colors.white,
      elevation: 2,
      toolbarHeight: toolbarHeight,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Logo
          Image.asset(logoAsset, height: toolbarHeight * 0.8, width: toolbarHeight * 0.8, fit: BoxFit.contain),
          const SizedBox(width: 8),

          // Text
          Text(
            titleText,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
