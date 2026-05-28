import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // (Optional) Untuk format tarikh cantik. Kalau tak ada, guna .toString()

class QuizHistoryScreen extends StatelessWidget {
  const QuizHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBE4),
      appBar: AppBar(
        title: const Text("Quiz History"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.indigo,
      ),
      body: user == null 
          ? const Center(child: Text("Please login first"))
          : StreamBuilder<QuerySnapshot>(
              // Tarik data dari collection 'quiz_history' user tersebut
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('quiz_history')
                  .orderBy('date', descending: true) // Susun paling baru di atas
                  .snapshots(),
              builder: (context, snapshot) {
                // 1. Tengah Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Kalau tiada data
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        const Text("No history yet. Take a quiz!"),
                      ],
                    ),
                  );
                }

                // 3. Ada Data - Paparkan dalam List
                final historyDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: historyDocs.length,
                  itemBuilder: (context, index) {
                    var data = historyDocs[index].data() as Map<String, dynamic>;
                    
                    // Format Tarikh (Kalau tak guna intl, boleh buang DateFormat ni)
                    Timestamp t = data['date'];
                    String dateString = DateFormat('dd MMM yyyy, hh:mm a').format(t.toDate());

                    // Tentukan Icon ikut jenis quiz
                    IconData icon = data['quizType'] == 'MBTI' 
                        ? Icons.psychology 
                        : Icons.work;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.only(bottom: 15),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: Colors.indigo),
                        ),
                        title: Text(
                          data['quizType'] ?? "Quiz",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              "Result: ${data['result']}", 
                              style: const TextStyle(color: Colors.black87, fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(dateString, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}