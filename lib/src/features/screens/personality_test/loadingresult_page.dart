import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfuture_application/src/features/screens/personality_test/mbti_result_display.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Uncomment if using Auth

class LoadingResultPage extends StatefulWidget {
  final String mbtiCode;
  final bool isNewResult;

  const LoadingResultPage({Key? key, required this.mbtiCode, this.isNewResult = false}) : super(key: key);

  @override
  _LoadingResultPageState createState() => _LoadingResultPageState();
}

class _LoadingResultPageState extends State<LoadingResultPage> {

  @override
  void initState() {
    super.initState();

    //access variable 
    print("Received MBTI: ${widget.mbtiCode}");

    _processAndFetchData();
  }

  Future<void> _processAndFetchData() async {
    //1. (Optional) Save the Result to the User's History in Firebase
     final user = FirebaseAuth.instance.currentUser;
     await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
       'mbti_type': widget.mbtiCode,
     }, 
     SetOptions(merge: true));

    try {
      // 2. Fetch the Description for this MBTI Type
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('mbti_results') // The collection we made in Step 1
          .doc(widget.mbtiCode)          // Searching for "INTJ"
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // 3. Navigate to the Final Result Page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MbtiResultDisplayPage(
                mbtiCode: widget.mbtiCode,
                data: data,
              ),
            ),
          );
        }
      }
      else {
        print("Document not found for ${widget.mbtiCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
      // Handle error (show a snackbar or retry button)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blueAccent),
            SizedBox(height: 20),
            Text("Analyzing your personality...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}