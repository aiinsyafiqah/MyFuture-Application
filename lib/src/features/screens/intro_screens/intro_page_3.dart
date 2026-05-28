import 'package:flutter/material.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class IntroPage2 extends StatelessWidget {
  

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        //text 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/gif/time.gif',
            width: 300,
            height: 300,
            
            ),

            
            SizedBox(height: 50,),

            //Text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('You feel running out of time',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),),
                  Text('choose whats best for you?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                  ),
                ],
              ),
            ), 
          ],
        ),
        
      ),
    );
  }
}