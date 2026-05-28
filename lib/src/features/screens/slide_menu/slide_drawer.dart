import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfuture_application/src/features/screens/slide_menu/change_password.dart';
import 'package:myfuture_application/src/features/screens/login/login_or_register_page.dart';
import 'package:myfuture_application/src/features/screens/slide_menu/quiz_history.dart';
import 'package:myfuture_application/src/features/screens/slide_menu/user_profile.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Dapatkan current user
    User? user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          // ==========================================================
          // GUNA STREAM BUILDER (LIVE UPDATE) - BUKAN FUTURE BUILDER
          // ==========================================================
          StreamBuilder<DocumentSnapshot>(
            // 1. Dengar perubahan terus dari database
            stream: (user != null) 
              ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
              : null, // Kalau tak login, takde stream
            
            builder: (context, snapshot) {
              String displayName = "Guest";
              String displayEmail = user?.email ?? "No Email";
              String displayImage = "";

              // 2. Proses data bila masuk
              if (snapshot.hasData && snapshot.data!.exists) {
                Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                displayName = data['name'] ?? "User";
                displayImage = data['image_url'] ?? "";
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 20),
                decoration: BoxDecoration(
                  color: primaryColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- GAMBAR PROFILE ---
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(
                        child: displayImage.isNotEmpty
                            ? Image.network(
                                displayImage,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.person, size: 50, color: Colors.grey),
                              )
                            : const Icon(Icons.person, size: 50, color: Colors.grey),
                      ),
                    ),

                    // --- NAMA (Akan bertukar automatik) ---
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // --- EMAIL ---
                    Text(
                      displayEmail,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 20,),
          
          // --- MENU ITEMS BAWAH ---
          ListTile(
            leading: Icon(Icons.person_outline, color: primaryColor),
            title: const Text("Edit Profile"),
            onTap: () {
              Navigator.pop(context); 
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => const EditProfilePage()));
            },
          ),

          const SizedBox(height: 20,),

          ListTile(
            leading: Icon(Icons.lock, color: primaryColor),
            title: const Text("Change Password"),
            onTap: () {
               Navigator.pop(context);
               Navigator.push(
                context, MaterialPageRoute(builder: (context) =>  ChangePasswordPage()));
            },
          ),

          const SizedBox(height: 20,),

           ListTile(
            leading: Icon(Icons.history, color: primaryColor),
            title: const Text("Quiz History"),
            onTap: () {
               Navigator.pop(context);
               Navigator.push(
                context, MaterialPageRoute(builder: (context) => const QuizHistoryScreen()));
            },
          ),

          const SizedBox(height: 20,),
          const Spacer(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Sign Out", style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
               await FirebaseAuth.instance.signOut();
               if (!context.mounted) return;
               
               Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) =>  const LoginOrRegisterPage()), 
                (route) => false
              );
            },
          ),

          Padding(
            padding:const EdgeInsets.only(bottom: 20.0),
            child: Text(
              "Version 1.0.0",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12
              ),
            ),)
        ],
      ),
    );
  }
}