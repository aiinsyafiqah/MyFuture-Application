import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfuture_application/models/mbti_questions_model.dart';

class DatabaseService {
  // Reference to the 'questions' collection in Firestore
  // MAKE SURE your collection in Firestore is actually named 'questions'
  final CollectionReference _questionRef =
      FirebaseFirestore.instance.collection('quiz_questions');

  // Function to fetch all questions once
  Future<List<Question>> getQuestions() async {
    try {
      // 1. Get the data from Firestore
      QuerySnapshot snapshot = await _questionRef.get();

      // 2. Convert each document into a Question object
      List<Question> questionList = snapshot.docs.map((doc) {
        // Get the data map
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Add the ID manually since it's not usually inside the data map
        data['id'] = doc.id; 

        // Use the factory method you created
        return Question.fromMap(data);
      }).toList();

      return questionList;
    } catch (e) {
      print("Error fetching questions: $e");
      return []; // Return empty list if something goes wrong
    }
  }
}