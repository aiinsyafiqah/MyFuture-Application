import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfuture_application/components/my_button.dart';
import 'package:myfuture_application/components/mytextfield.dart';
import 'package:myfuture_application/src/features/screens/forgot_password/forgot_password.dart';
import 'package:myfuture_application/src/features/screens/homepage/homepage.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  //sign in user method
  void signUserIn() async {
    //validate inputs
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showErrorMessage("Please enter both email and password");
      return;
    }

    if (!email.contains('@')) {
      showErrorMessage("Please enter a valid email address");
      return;
    }

    //show loading circle
    setState(() {
      _isLoading = true;
    });

    //try sign in
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (user != null) {
        // --- SENARIO 1: SUDAH VERIFIED ---
        if (user.emailVerified) {
          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'isVerified': true});
          } catch (e) {
            print("Error updating database: $e");
          }

          if (mounted) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Homepage()));
          }
        }
        // --- SENARIO 2: BELUM VERIFIED ---
        else {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text("Email Not Verified"),
                      content: const Text(
                          "Please check your email and verify your account"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("OK")),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              // Logic Resend Email boleh letak sini
                            },
                            child: const Text("Resend Email"))
                      ],
                    ));
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showErrorMessage(getUserFriendlyError(e.code));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showErrorMessage("An unexpected error occurred");
      }
    }
  }

  String getUserFriendlyError(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return "No account found with this email";
      case 'wrong-password':
        return 'Incorrect email or password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'An error has occurred. $errorCode';
    }
  }

  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.red,
            title: Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Dapatkan ketinggian skrin phone user
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SizedBox(
          height: screenHeight, // Paksa container ambil tinggi penuh skrin
          child: SingleChildScrollView(
            // SingleChildScrollView kekal ada supaya bila keyboard naik, user masih boleh scroll
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              // Container dalaman ni akan set minima tinggi ikut skrin
              // Supaya content duduk tengah-tengah bila keyboard tak ada
              height: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom, 
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Centerkan semua vertical
                  crossAxisAlignment: CrossAxisAlignment.start, // <--- PENTING: Semua text rapat kiri (Start)
                  children: [
                    
                    // --- LOGO (Kena bungkus dengan Center sebab Column dah set rapat kiri) ---
                    Center(
                      child: Image.asset(
                        'assets/logo/myfuture_logo.png',
                        height: screenHeight * 0.20, 
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02), 

                    // Welcome Text (Kena bungkus dengan Center juga)
                    Center(
                      child: Text(
                        'Welcome back, you\'ve been missed!',
                        style: TextStyle(color: primaryColor, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // --- EMAIL LABEL ---
                    // SAYA DAH BUANG 'left: 5'. Sekarang dia akan rapat kiri sama dengan TextField.
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8), 
                      child: Text(
                        'Email',
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Mytextfield(
                      controller: emailController,
                      obscureText: false,
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // --- PASSWORD LABEL ---
                    // SAYA DAH BUANG 'left: 5' DI SINI JUGA
                    const Padding(
                       padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Password',
                        style: TextStyle(
                            color: primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Mytextfield(
                      controller: passwordController,
                      obscureText: _isObscure,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Forgot Password (Align Right - guna Row & MainAxisAlignment.end macam asal)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgetPasswordScreen()));
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Sign In Button
                    MyButton(
                      text: _isLoading ? 'Signing in...' : 'Sign In',
                      onTap: _isLoading ? null : signUserIn,
                    ),

                    if (_isLoading) ...[
                      const SizedBox(height: 20),
                      const Center(child: CircularProgressIndicator()), // Centerkan loading
                    ],

                    SizedBox(height: screenHeight * 0.03),

                    // Or continue with
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Register Now (Kekal dalam Row & Center alignment)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Not a member?',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            'Register Now',
                            style: TextStyle(
                                color: primaryColor, fontWeight: FontWeight.bold),
                          ),
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