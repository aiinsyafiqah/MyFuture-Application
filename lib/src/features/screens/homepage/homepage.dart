// FILE: src/features/screens/homepage.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfuture_application/src/features/screens/homepage/homepage_content.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';
import 'package:myfuture_application/src/features/controllers/bottomNavigationBar.dart';
import 'package:myfuture_application/src/features/screens/scholarships/scholarships_page.dart';
import 'package:myfuture_application/src/features/screens/career_test/career_page.dart';
import 'package:myfuture_application/src/features/screens/personality_test/front_quiz_page.dart';

class Homepage extends StatefulWidget {
  final int initialIndex;
  const Homepage({super.key,
  this.initialIndex = 0}); // <--- INI PENTING

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // 1. Jangan letak 'late' dan value terus macam tadi
  late int _selectedIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // 2. TANGKAP VALUE DARI WIDGET DI SINI
    _selectedIndex = widget.initialIndex; 
    _checkVerificationStatus();
    
    // 3. SET CONTROLLER SUPAYA MULA DI PAGE YANG DIMINTA
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  Future<void> _checkVerificationStatus() async {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    await user.reload(); // Wajib reload untuk refresh status
    user = FirebaseAuth.instance.currentUser;

    if (user!.emailVerified) {
      // Update senyap-senyap di background
      // Kita guna .update() supaya tak kacau field lain
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'isVerified': true,
      });
    }
  }
}


  void _jumpToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... bahagian build awak kekal sama ...
    final List<Widget> pages = [
      HomepageContent( 
        onGoToCareer: () {
          _jumpToTab(2); 
        },
      ),
      const ScholarshipsPageContent(),
      const CareerPageContent(),
      const QuizFrontPage(),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => _jumpToTab(index),
      ),
    );
  }
}