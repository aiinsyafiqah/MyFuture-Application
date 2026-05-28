import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class MyBottomNavigationBar extends StatelessWidget {
  final Function(int)? onTap;
  final int selectedIndex;

  const MyBottomNavigationBar({
    super.key,
    this.onTap,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: backgroundColor,
      animationDuration: const Duration(milliseconds: 300),
      index: selectedIndex,
      onTap: onTap ?? (index) {
        print(index);
      },
      color: primaryColor,
      items: const [
        Icon(Icons.home, 
        color: Colors.white,),
        Icon(Icons.favorite,
        color: Colors.white,), // scholarships
        Icon(Icons.work,
        color: Colors.white,), // career
        Icon(Icons.quiz,
        color: Colors.white,), // user
      ],
    );
  }
}
