import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';

class CareerTestScreen extends StatefulWidget {
  const CareerTestScreen({super.key});

  @override
  State<CareerTestScreen> createState() => _CareerTestScreenState();
}

class _CareerTestScreenState extends State<CareerTestScreen> {

  // --- PASTE THE UPLOAD FUNCTION HERE ---
  Future<void> uploadQuestionsToFirebase() async {
    try {
      String jsonString = await rootBundle.loadString('assets/careers/career_lists.json');
      List<dynamic> jsonList = jsonDecode(jsonString);

      WriteBatch batch = FirebaseFirestore.instance.batch();
      CollectionReference questionsRef = FirebaseFirestore.instance.collection('career_lists');

      for (var item in jsonList) {
        DocumentReference docRef = questionsRef.doc(item['id']);
        batch.set(docRef, item);
      }

      await batch.commit();
      
      // Show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Data Uploaded Successfully!')),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  // --------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Career Lists")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("This is the test screen"),
            const SizedBox(height: 20),
            
            // --- YOUR TEMPORARY BUTTON ---
            ElevatedButton.icon(
              onPressed: uploadQuestionsToFirebase,
              icon: const Icon(Icons.cloud_upload),
              label: const Text("ADMIN: Upload Questions"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
            // -----------------------------
          ],
        ),
      ),
    );
  }
}