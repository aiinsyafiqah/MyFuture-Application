import 'package:flutter/material.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class IntroPage1 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        //text 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/gif/thinking.gif',
            width: 300,
            height: 350,
            
            ),

            
            SizedBox(height: 20,),

            //Text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Confused on what',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),),
                  Text('scholarships or courses you should choose ?',
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