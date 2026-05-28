import 'package:flutter/material.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  const SquareTile({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color : backgroundColor),
        borderRadius: BorderRadius.circular(16),
        color: backgroundColor
      ),
      
      child: Image.asset(imagePath,
      height: 40,),
    );
  }
}