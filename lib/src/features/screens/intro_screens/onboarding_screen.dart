import 'package:flutter/material.dart';
import 'package:myfuture_application/src/features/screens/intro_screens/intro_page_1.dart';
import 'package:myfuture_application/src/features/screens/intro_screens/intro_page_2.dart';
import 'package:myfuture_application/src/features/screens/intro_screens/intro_page_3.dart';
import 'package:myfuture_application/src/features/screens/login/login_or_register_page.dart';
import 'package:myfuture_application/src/features/screens/login/login_page.dart';
import 'package:myfuture_application/src/features/screens/sign_up/register.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {

  //controller keep track of page we're on
  PageController _controller = PageController();

  //keep track if we're on the last page or not 
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,

            //if we're on the last page 
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
              
            },
            children: [
              IntroPage1(),
              IntroPage2(),
              IntroPage3(),
            ],
          ),

          //dot indicator
          Container(
            //positive number towards the bottom
            alignment: Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [


                //skip
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                  child: Text('skip'),
                  ),



                //dot indicator
                SmoothPageIndicator(
                  controller: _controller, count: 3),

                //next or done 
                onLastPage ?
                GestureDetector(
                  onTap:() {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                      return LoginOrRegisterPage();
                    }));
                  },
                  child: Text('done')
                )
                : GestureDetector(
                  onTap: () {
                    _controller.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn);
                  },
                  child: Text('next'),
                )
              ],
            )),
        ],
      )
    );
  }
}