import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfuture_application/src/features/screens/homepage/homepage.dart';
import 'package:myfuture_application/src/features/screens/login/login_or_register_page.dart';
import 'package:myfuture_application/src/features/screens/login/login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          //if user login 
          if(snapshot.hasData && snapshot.data !=null){
            print('User logged in : ${snapshot.data!.uid}');
            return Homepage();
          }

          //user not logged in 
          else{
            print('User not logged in');
            return LoginOrRegisterPage();
          }
        },
      )
    );
  }
}