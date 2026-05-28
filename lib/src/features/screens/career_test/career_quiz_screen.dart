import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfuture_application/src/features/screens/career_test/career_result_page.dart';
import 'package:myfuture_application/src/features/screens/homepage/homepage.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart'; 

class CareerQuizScreen extends StatefulWidget {
  const CareerQuizScreen({super.key});

  @override
  _CareerQuizScreenState createState() => _CareerQuizScreenState();
}

class _CareerQuizScreenState extends State<CareerQuizScreen> {
  // 1. Data Variables
  List<List<Map<String, dynamic>>> _quizRounds = []; 
  int _currentRoundIndex = 0;
  bool _isLoading = true;

  // Track selection
  String? _selectedQuestion;

  // 2. Score Tracker
  final Map<String, int> _riasecScores = {
    'R': 0, 'I': 0, 'A': 0, 'S': 0, 'E': 0, 'C': 0
  };

  final List<String> _selectionHistory = [];

  @override
  void initState() {
    super.initState();
    _loadAndGroupQuestions();
  }

  // --- LOAD DATA ---
  Future<void> _loadAndGroupQuestions() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('career_questions')
          .get();

      List<Map<String, dynamic>> allQuestions = snapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      allQuestions.shuffle();

      List<List<Map<String, dynamic>>> chunks = [];
      int chunkSize = 4;
      
      for (var i = 0; i < allQuestions.length; i += chunkSize) {
        int end = (i + chunkSize < allQuestions.length) ? i + chunkSize : allQuestions.length;
        chunks.add(allQuestions.sublist(i, end));
      }

      setState(() {
        _quizRounds = chunks;
        _isLoading = false;
      });

    } catch (e) {
      print("Error organizing rounds: $e");
    }
  }

  void _onCardTap(String questionText){
    setState(() {
      _selectedQuestion = questionText;
    });
  }

  // --- LOGIC BUTTONS ---
  void _onNextPressed() {
    if(_selectedQuestion == null) return;
     
     var currentOptions = _quizRounds[_currentRoundIndex];
     var selectedOption = currentOptions.firstWhere(
      (option) => option['question_text'] == _selectedQuestion
     );

     String category = selectedOption['category']; 
     _riasecScores[category] = (_riasecScores[category] ?? 0) + 1;
     _selectionHistory.add(category);

     if(_currentRoundIndex < _quizRounds.length - 1){
      setState(() {
        _currentRoundIndex++;
        _selectedQuestion = null;
      });
     } else {
      _finishQuiz();
     }
  }

  void _goBack() {
    if (_currentRoundIndex > 0 && _selectionHistory.isNotEmpty) {
      String lastPickedCategory = _selectionHistory.removeLast();
      if (_riasecScores[lastPickedCategory] != null) {
        _riasecScores[lastPickedCategory] = _riasecScores[lastPickedCategory]! - 1;
      }
      setState(() {
        _currentRoundIndex--;
        _selectedQuestion = null; 
      });
    }
  }

  Future<void> _finishQuiz() async {
    var sortedEntries = _riasecScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); 

    String topCode = "${sortedEntries[0].key}${sortedEntries[1].key}${sortedEntries[2].key}";
    
   User? user = FirebaseAuth.instance.currentUser;

   if(user != null){
    try{
      await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({
        'riasec_code' : topCode,
        'riasec_scores' : _riasecScores,
        'last_career_test' : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch(e){
      print("Error saving results : $e");
    }
   }
   
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => CareerResultDisplayPage(
      topCode: topCode,
      isNewResult: true)));
  }

  Future<bool> _onWillPop() async{
    return (await showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Quit Quiz", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
        content: const Text('Are you sure you want to quit? Your progress will be lost.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          ElevatedButton(
            onPressed: (){
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Homepage(initialIndex: 3,)), 
                (route) => false);
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
            ),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
            ),
            child: const Text('Quit'),
          ),
        ],
      ))) ?? false; 
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_quizRounds.isEmpty) return const Scaffold(body: Center(child: Text("Not enough questions loaded.")));

    List<Map<String, dynamic>> currentOptions = _quizRounds[_currentRoundIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: backgroundColor, 
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10), // Kurangkan padding vertical
            child: Column(
              children: [
                // --- HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.maybePop(context); 
                      },
                      icon: Icon(Icons.arrow_back_ios_new_outlined, color: primaryColor),
                    ),
                    Expanded(
                      child: Text(
                        'CAREER TEST',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), 
                  ],
                ),
                
                const SizedBox(height: 10),
                Text("Question ${_currentRoundIndex + 1} of ${_quizRounds.length}",
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),

                const SizedBox(height: 10),

                // -- QUESTION TITLE --
                // Guna Flexible supaya text tak makan ruang melampau
                const Text("What activities would \nyou enjoy the most?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22, // Kecilkan sikit font
                  ),
                ),
                
                const SizedBox(height: 15),

                // --- THE 4 OPTIONS (Auto Fit Screen) ---
                Expanded(
                  // LayoutBuilder KUNCI KEJAYAAN: Dia ukur ruang yang tinggal
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Kita nak 2 Rows, 2 Columns.
                      // Jadi tinggi satu kad = Tinggi Ruang / 2
                      // Lebar satu kad = Lebar Ruang / 2
                      double itemHeight = (constraints.maxHeight - 15) / 2; // -15 tu untuk spacing
                      double itemWidth = (constraints.maxWidth - 15) / 2;
                      
                      // Dapatkan Aspect Ratio yang TEPAT supaya muat
                      double childAspectRatio = itemWidth / itemHeight;

                      return GridView.builder(
                        // MATIKAN SCROLL
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentOptions.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, 
                          crossAxisSpacing: 15, 
                          mainAxisSpacing: 15, 
                          childAspectRatio: childAspectRatio, // Ratio automatik!
                        ),
                        itemBuilder: (ctx, index) {
                          var option = currentOptions[index];
                          bool isSelected = _selectedQuestion == option['question_text'];
                          
                          return _buildGridCard(
                            text: option['question_text'],
                            category: option['category'],
                            imageUrl: option['image_url'],
                            isSelected: isSelected,
                            onTap: () => _onCardTap(option['question_text']),
                          );
                        },
                      );
                    }
                  ),  
                ),

                const SizedBox(height: 15),

                // --- BOTTOM BUTTONS ---
                SizedBox(
                  height: 55, // Tetapkan tinggi container butang
                  child: Row(
                    children: [
                      // BACK BUTTON
                      if (_currentRoundIndex > 0) 
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0), 
                            child: OutlinedButton(
                              onPressed: _goBack,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.blueAccent, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text("Back", style: TextStyle(fontSize: 18, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),

                      // NEXT BUTTON
                      Expanded(
                        flex: 2, 
                        child: ElevatedButton(
                          onPressed: _selectedQuestion == null ? null : _onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 2,
                          ),
                          child: Text(
                            _currentRoundIndex == _quizRounds.length - 1 ? "Finish" : "Next",
                            style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Tambah sikit padding bawah sekali untuk iPhone (Home indicator)
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGET ---
  Widget _buildGridCard({
    required String text, 
    required String category,
    required String? imageUrl,
    required bool isSelected,
    required VoidCallback onTap}) {

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          // KOTAK LUAR: Warna akan jadi biru kalau select, putih kalau tak.
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          
          // Border tebal biru kalau select
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.withOpacity(0.2),
            width: isSelected ? 3 : 1
          ),

          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5)
            )
          ]
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image
              Expanded(
                flex: 2, // Bagi gambar ruang lebih
                child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported, color: Colors.grey);
                  },
                ) : const Icon(Icons.star_border_rounded, size: 40, color: Colors.blueAccent)
              ),
              
              const SizedBox(height: 8),
              
              // Text
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: 3, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12, // Font kecik sikit supaya muat
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? primaryColor : Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}