import 'package:flutter/material.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class IntroPage3 extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        //text 1
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/gif/aeroplane.gif',
            height: 450,
            width: 400,
            ), 

            //Text
            Text('MyFuture is your choice !',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
            ),
          ],
        ),  
      ),
    );
  }
}