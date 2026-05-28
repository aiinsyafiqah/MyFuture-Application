import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfuture_application/src/features/screens/career_test/career_page.dart';
import 'package:myfuture_application/src/features/screens/homepage/homepage.dart';
import 'package:myfuture_application/src/features/screens/pathways/final_result.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class CareerResultDisplayPage extends StatefulWidget {
  final String topCode; // e.g. "ASE"
  final bool isNewResult;

  const CareerResultDisplayPage({super.key, required this.topCode, this.isNewResult = false});
 
  @override
  State<CareerResultDisplayPage> createState() => _CareerResultDisplayPageState();
}

class _CareerResultDisplayPageState extends State<CareerResultDisplayPage> {
  
  final Map<String, Color> myCustomColors = {
    'R': const Color(0xFFD32F2F), 
    'I': const Color(0xFFF57C00), 
    'A': const Color(0xFF7B1FA2), 
    'S': const Color(0xFF1976D2), 
    'E': const Color(0xFF388E3C), 
    'C': const Color(0xFF00796B), 
  };

  Map<String, dynamic>? primaryInfoData;
  List<String> allCombinedJobs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResults();

    if(widget.isNewResult){
       _saveQuizHistory();
    }
   
  }

  // save result dalam history 
  Future<void> _saveQuizHistory() async {
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('quiz_history') // Masuk dalam collection history
            .add({
              'quizType': 'Holland Code', // Nama jenis kuiz
              'result': widget.topCode,   // Result dia (Contoh: "ASE")
              'date': FieldValue.serverTimestamp(), // Tarikh & masa sekarang
            });
        print("Quiz history saved successfully: ${widget.topCode}");
      } catch (e) {
        print("Failed to save history: $e");
      }
    }
  }

  Future<void> _fetchResults() async {
    try {
      final Map<String, String> codeToTagMap = {
        'R': 'Realistic', 'I': 'Investigative', 'A': 'Artistic',
        'S': 'Social', 'E': 'Enterprising', 'C': 'Conventional',
      };

      List<String> letters = widget.topCode.split(''); 
      List<String> tempAllJobs = [];
      Map<String, dynamic>? tempPrimaryData;

      // Loop setiap huruf (Cth: A, S, E)
      for (int i = 0; i < letters.length; i++) {
        String letter = letters[i];
        
        // --- 1. PEMBETULAN UTAMA DI SINI ---
        // Kita mesti tarik data description untuk huruf pertama (Dominant Code)
        if (i == 0) {
          DocumentSnapshot infoDoc = await FirebaseFirestore.instance
              .collection('career_results') // Pastikan collection ni wujud
              .doc(letter) // e.g. doc ID ialah 'A', 'R', etc.
              .get();
          
          if (infoDoc.exists) {
            tempPrimaryData = infoDoc.data() as Map<String, dynamic>;
          }
        }
        // ------------------------------------

        // 2. Ambil Senarai Kerja berdasarkan Tag
        String? dbTag = codeToTagMap[letter];
        QuerySnapshot jobQuery = await FirebaseFirestore.instance
            .collection('career_lists')
            .where('riasec_tag', isEqualTo: dbTag) 
            .get();

        List<String> jobsFromThisLetter = jobQuery.docs.map((doc) => doc.id).toList();
        tempAllJobs.addAll(jobsFromThisLetter);
      }

      // 3. Logic: Buang Duplicate & Limit 5
      tempAllJobs = tempAllJobs.toSet().toList(); // Buang duplicate

      if (tempAllJobs.length > 5) {
        tempAllJobs = tempAllJobs.sublist(0, 5); // Ambil 5 teratas sahaja
      }

      // Update State
      if (mounted) {
        setState(() {
          primaryInfoData = tempPrimaryData;
          allCombinedJobs = tempAllJobs;
          isLoading = false;
        });
      }

    } catch (e) {
      print("Error fetching results: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    // Safety check: Kalau data description tak jumpa dalam database
    if (primaryInfoData == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text("Result info not found for code: ${widget.topCode}"),
        ),
      );
    }

    String primaryLetter = widget.topCode[0];
    Color themeColor = myCustomColors[primaryLetter] ?? primaryColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10, 
                bottom: 40, left: 20, right: 20
              ),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [BoxShadow(color: themeColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 10))]
              ),
              child: Column(
                children: [
                  
                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  
                  const SizedBox(height: 10),

                  const Text("You are ", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5),
                  Text(
                    primaryInfoData!['name'] ?? "Unknown",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      primaryInfoData!['description'] ?? "No description available.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
      
            const SizedBox(height: 30),
            
            // --- TAJUK LIST ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.work_history_rounded, color: themeColor),
                  const SizedBox(width: 10),
                  Text(
                    "Recommended Careers",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                    ),
                  ),
                ],
              ),
            ),

            // --- LIST KERJA ---
            if (allCombinedJobs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("No specific careers found yet."),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: allCombinedJobs.map((job) {
                    return GestureDetector(
                      onTap: () {
                        // 1. UPDATE DATABASE (Naikkan view_count)
                        FirebaseFirestore.instance
                            .collection('career_lists')
                            .doc(job)
                            .update({
                              'view_count': FieldValue.increment(1), 
                            }).catchError((e) {
                               // Create field jika belum wujud
                               FirebaseFirestore.instance
                                  .collection('career_lists')
                                  .doc(job)
                                  .set({'view_count': 1}, SetOptions(merge: true));
                            });

                        // 2. NAVIGATE KE PAGE DETAIL
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => CareerPathwaysScreen(jobTitle: job))
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: themeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: Icon(Icons.work_outline, color: themeColor, size: 20),
                            ),
                            const SizedBox(width: 15),
                            Expanded(child: Text(job, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87))),
                            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400])
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
      
            // --- BUTTON HOME ---
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0, top: 20),
              child: ElevatedButton.icon(
                onPressed: () {
                 Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Homepage(initialIndex: 2)),
                  (route) => false,
                  );
                },
                label: const Text("View More Career", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}