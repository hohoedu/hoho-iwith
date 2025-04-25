import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? color;

  const MainAppBar({super.key, required this.title, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: color,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/images/icon/back.png',
            scale: 2.5,
          ),
        ),
      ),
      title: Text(title),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
