import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfuture_application/components/custom_dialogs.dart';
import 'package:myfuture_application/components/my_button.dart';
import 'package:myfuture_application/components/mytextfield.dart';
import 'package:myfuture_application/src/features/screens/login/auth_page.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmedPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordHidden = true;
  bool _isConfirmedPasswordHidden = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmedPasswordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  //sign in user method
  void signUserUp() async { 

    if(_isLoading) return;

    //validate inputs 
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmedPasswordController.text.trim();
    final username = usernameController.text.trim();

    if(email.isEmpty || password.isEmpty){
      CustomDialogs.showErrorMessage(context,"Please enter email and password");
      return;
    }

    if(!email.contains('@')){
      CustomDialogs.showErrorMessage(context,"Please enter a valid email address");    
      return;
    }

    //show loading circle
    setState(() {
      _isLoading = true;
    });

    //try creating the user
    try{
      
      //check if the password and confirm password is the same 
      if(password != confirmPassword){
        setState(() {
          _isLoading = false;
        });
        CustomDialogs.showErrorMessage(context,"Password don't match !");
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    //send email verification 
    if(userCredential.user != null){

      await userCredential.user!.updateDisplayName(username);

       // SAVE USER DETAILS IN THE FIRESTORE 
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name' : username,
        'email' : email,
        'role' : 'student',
        'created_at' : Timestamp.now(),
        'isVerified' : false,
      });

      await userCredential.user!.sendEmailVerification();

      await FirebaseAuth.instance.signOut();

      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }

      if(!mounted) return;

      // show pop up message cakap verify account dekat email
      showDialog(
        context: context, 
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Verify Your Email"),
          content: const Text("A verification link has been sent to your email.\n Please verify your account \n If email does not exist check spam"),
          actions: [
            TextButton(onPressed: (){
              //pergi login page 
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (context) => AuthPage()),
                (route) => false
                );
            }, 
            child: const Text("OK"))
          ],
        ));
    }

      if(!mounted){
        setState(() {
        _isLoading = false;
      });
      }

    } on FirebaseAuthException catch (e){
      //pop up the loading circle
      setState(() {
        _isLoading = false;
      });
      
      //show error message 
      showErrorMessage(getUserFriendlyError(e.code));
    } catch (e, stackTrace) {
      if(mounted){
        setState(() {
        _isLoading = false;
      });
      }
      print('Unexpected Error: $e');
      print('Stack Trace: $stackTrace');
      
      showErrorMessage("An unexpected error occurred: ${e.toString()}");
    }
  }

  //error message handling 
  String getUserFriendlyError(String errorCode){
    switch(errorCode){
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return "No account found with this email";
      case 'wrong-password':
        return 'Incorrect email or password';
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'An error has occurred. \n $errorCode';
    }
  }
    //error message to user 
    void showErrorMessage(String message){
      showDialog(
        context: context,
        builder: (context){
          return  AlertDialog(
            backgroundColor: Colors.red,
            title: Center(
              child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
              ),
            ),
          );
        }
        );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Dapatkan tinggi skrin
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SizedBox(
          height: screenHeight, // Paksa container penuhkan skrin
          child: SingleChildScrollView(
            // ClampingScrollPhysics menghalang kesan 'bounce' berlebihan
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              // Formula ini memastikan content berada di tengah bila keyboard tutup,
              // tapi membenarkan scroll bila keyboard buka.
              height: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom, 
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center content
                  children: [
                      
                    // --- LOGO (KECILKAN SIKIT UNTUK REGISTER) ---
                    // Sebab register ada banyak field, kita guna 15% je dari skrin
                    Image.asset(
                      'assets/logo/myfuture_logo.png',
                      height: screenHeight * 0.15, 
                      fit: BoxFit.contain,
                    ),
                      
                    SizedBox(height: screenHeight * 0.02),
                
                    // Title
                    Text(
                      'Your new journey starts here!',
                      style: TextStyle(
                        color: primaryColor, 
                        fontSize: 18), // Font sederhana
                    ),
                
                    SizedBox(height: screenHeight * 0.02),

                    // --- USERNAME ---
                    // Guna Align lebih kemas dari Row
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, bottom: 5),
                        child: Text('Username', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Mytextfield(
                      controller: usernameController,
                      obscureText: false,
                    ),

                     SizedBox(height: screenHeight * 0.015), // Jarak kecil sikit antara field

                    // --- EMAIL ---
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, bottom: 5),
                        child: Text('Email', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Mytextfield(
                      controller: emailController,
                      obscureText: false,
                    ),
                
                    SizedBox(height: screenHeight * 0.015),
                
                    // --- PASSWORD ---
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, bottom: 5),
                        child: Text('Password', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Mytextfield(
                      controller: passwordController, 
                      obscureText: _isPasswordHidden,
                      suffixIcon: IconButton(
                        onPressed: (){
                          setState(() {
                            _isPasswordHidden = !_isPasswordHidden;
                          });
                      }, icon: Icon(_isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      )),
                    ),
                
                    SizedBox(height: screenHeight * 0.015),

                    // --- CONFIRM PASSWORD ---
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, bottom: 5),
                        child: Text('Confirm Password', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Mytextfield(
                      controller: confirmedPasswordController, 
                      obscureText: _isConfirmedPasswordHidden,
                      suffixIcon: IconButton(
                        onPressed: (){
                          setState(() {
                            _isConfirmedPasswordHidden = !_isConfirmedPasswordHidden;
                          });
                      }, 
                      icon: Icon(_isConfirmedPasswordHidden ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      )),
                    ),
     
                    SizedBox(height: screenHeight * 0.03),
                
                    // Sign Up Button
                    MyButton(
                      text: _isLoading ? 'Creating account...' : 'Sign Up',
                      onTap: _isLoading ? null : signUserUp,
                    ),

                    if(_isLoading) ...[
                      const SizedBox(height: 10),
                      const CircularProgressIndicator(),
                    ],
                  
                    SizedBox(height: screenHeight * 0.02),
                
                    // Or continue with
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        children: [
                          Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('Or continue with', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                          ),
                          Expanded(child: Divider(thickness: 0.5, color: Colors.grey[400])),
                        ],
                      ),
                    ),
                  
                    SizedBox(height: screenHeight * 0.02),
                
                    // Sign In Here
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account?', style: TextStyle(color:Colors.grey)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text('Sign In', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}