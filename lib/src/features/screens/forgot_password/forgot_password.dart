import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfuture_application/components/custom_dialogs.dart';
import 'package:myfuture_application/src/features/screens/login/login_or_register_page.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void resetPassword(BuildContext context) async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
       CustomDialogs.showErrorMessage(context,"Please enter your email");
      return;
    }

    showDialog(
     context: context,
     barrierDismissible: false, // user can't click outside to close 
     builder: (context) => const Center(
      child: CircularProgressIndicator(),
     )
    );

    try {

      //send the reset email 
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      //pop loading circle 
      if (context.mounted) Navigator.pop(context);

      //success message
     CustomDialogs.showSuccessMessage(
        context,
        "Reset password email successfully send! ",
        buttonText: 'OK',
        onContinue: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginOrRegisterPage()),
            (route) => false,
          );
        },
      );
    } on FirebaseAuthException catch (e){

      if (context.mounted) Navigator.pop(context);

      //handle errors
      String showErrorMessage = e.message ?? "An error occured";

      if(e.code == 'user-not-found'){
        showErrorMessage = "Email does not exist";
      }
    } 
    catch (e) {
      CustomDialogs.showErrorMessage(context,"Please enter your email");
      return; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: SingleChildScrollView( // For smaller screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context)=> const LoginOrRegisterPage()));// Go back to quiz front page 
                      },
                      icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
                    ),
                    Expanded(
                      child: Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // Balances the arrow width
                  ],
                ),

                SizedBox(height: 50,),
                // Center Image
                SizedBox(
                  height: 200,
                  child: Image.asset('assets/images/forgot.png'), // Update with your image path
                ),
                const SizedBox(height: 30.0),
        
                // Text
                 Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text(
                      "Please Enter Your Email Address To \n reset your password",
                      style: TextStyle(
                        fontSize: 18
                      ),
                      textAlign: TextAlign.center,
                                     ),
                   
                const SizedBox(height: 30.0),
        
                // Email Input
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: "ali@gmail.com",
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 50.0),
        
                // Reset Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    )
                  ),
                  onPressed: () => resetPassword(context),
                  child: const Text('Send Reset Link',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),),
                ),
                ],
               ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}