import 'package:flutter/material.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class Mytextfield extends StatelessWidget {
  //controller is used to access information inside the textfield
  final controller;
  final bool obscureText;

  //icon mata for password
  final Widget? suffixIcon;

  const Mytextfield({
    super.key,
    required this.controller,
    required this.obscureText,
    this.suffixIcon
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText, //hide user punya password time type
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: backgroundColor),
        ),

        suffixIcon: suffixIcon,
        
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey)
        ),
        fillColor: Colors.grey.shade200,
        filled: true,
        //bagi hint dekat user dalam textfield tu nak letak apa 
        hintStyle: TextStyle(color:Colors.grey[500]),
      ),
    );
  }
}