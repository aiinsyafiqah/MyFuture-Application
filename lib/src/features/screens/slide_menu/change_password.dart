import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;

  // Show/Hide Password
  bool showCurrentPassword = false;
  bool showNewPassword = false;

  // Password validation
  bool isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~])[A-Za-z\d!@#\$&*~]{12,}$');
    return regex.hasMatch(password);
  }

  Future<void> _changePassword() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;

      if (user == null) {
        throw Exception('No user is logged in');
      }

      String email = user.email!;

      // Validate new password
      String newPassword = newPasswordController.text.trim();
      if (!isPasswordValid(newPassword)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password must be at least 12 characters, include 1 uppercase, and 1 special character.')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Check if current password and new password are the same
        if (currentPasswordController.text.trim() == newPasswordController.text.trim()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('New password cannot be the same as the current password.')),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }


      // Reauthenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('Password successfully changed!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close popup
                Navigator.pop(context); // Go back to previous page
              },
              child: Text('OK'),
            ),
          ],
        ),
      );


    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect current password.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The new password is too weak.';
      } else {
        errorMessage = 'Error: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [

              //back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context); // Fungsi untuk back
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios, 
                          size: 24,
                          color: primaryColor,),
                        padding: EdgeInsets.zero, // Hilangkan padding extra supaya rapat tepi
                        constraints: const BoxConstraints(), // Kecilkan ruang button
                      ),
                    ),

              Image.asset('assets/images/change_password.png',
                          width: 300,
                          height: 250,),

              SizedBox(height: 50,),

              // Current Password Field
              TextField(
                controller: currentPasswordController,
                obscureText: !showCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.white
                    )
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showCurrentPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        showCurrentPassword = !showCurrentPassword;
                      });
                    },
                  ),
                ),
              ),
              
              SizedBox(height: 20),
        
              // New Password Field
              TextField(
                controller: newPasswordController,
                obscureText: !showNewPassword,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.white
                    )
                  ),
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      showNewPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        showNewPassword = !showNewPassword;
                      });
                    },
                  ),
                ),
              ),
        
              SizedBox(height: 40),
        
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        side: BorderSide(color: primaryColor),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      child: Text('Change Password',
                        style: 
                        TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700
                        )
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

