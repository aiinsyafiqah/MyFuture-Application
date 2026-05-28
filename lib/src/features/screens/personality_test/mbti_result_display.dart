import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfuture_application/src/features/controllers/bottomNavigationBar.dart';
import 'package:myfuture_application/src/features/screens/career_test/career_page.dart';
import 'package:myfuture_application/src/features/screens/career_test/career_quiz_screen.dart';
import 'package:myfuture_application/src/features/screens/homepage/homepage.dart';
import 'package:myfuture_application/src/features/screens/personality_test/all_personality.dart';
import 'package:myfuture_application/src/features/screens/personality_test/front_quiz_page.dart';
import 'package:myfuture_application/src/features/screens/scholarships/scholarships_page.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class MbtiResultDisplayPage extends StatefulWidget {
  final String mbtiCode; // "INTJ"
  final Map<String, dynamic> data; // The data from Firestore

  final bool isNewResult;

const MbtiResultDisplayPage({Key? key, required this.mbtiCode, required this.data, this.isNewResult = false}) : super(key: key);

  @override
  State<MbtiResultDisplayPage> createState() => _MbtiResultDisplayPageState();
}

class _MbtiResultDisplayPageState extends State<MbtiResultDisplayPage> {
  int _selectedIndex = 3;
  final PageController _pageController = PageController();
  
  // --- 1. THE DICTIONARY ---
  final Map<String,String> traitDefinitions = {
    'E': 'Extraverted' , 'I' : 'Introverted',
    'S': 'Sensing' , 'N' : 'Intuitive',
    'T': 'Thinking', 'F' : 'Feeling',
    'J': 'Judging', 'P' : 'Perceiving'
  };

  @override
  void initState(){
    super.initState();

    if (widget.isNewResult){
      _saveMbtiHistory();
    }
    
  }

  // --- 3. FUNCTION SIMPAN HISTORY KE DATABASE ---
  Future<void> _saveMbtiHistory() async {
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('quiz_history') // Masuk collection history yang sama
            .add({
              'quizType': 'MBTI',        // Label jenis kuiz
              'result': widget.mbtiCode, // Result dia (Contoh: "INTJ")
              'date': FieldValue.serverTimestamp(), // Tarikh sekarang
            });
        print("MBTI history saved: ${widget.mbtiCode}");
      } catch (e) {
        print("Failed to save MBTI history: $e");
      }
    }
  }

  //bottomNavigator 
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Widget targetPage;

    // Kita guna Switch Case untuk tentukan arah tuju
    switch (index) {
      case 0: 
        targetPage = const Homepage(initialIndex: 0);
        break;

      case 1:
        targetPage = const ScholarshipsPageContent();
        break;
      
      case 2: 
        targetPage = const CareerPageContent();
        break;

      case 3: 
        return;
      
      default:
        return;
    }

    Navigator.pushAndRemoveUntil(
      context, 
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // 'animation' ni nilai dia 0.0 sampai 1.0
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }
  @override
  Widget build(BuildContext context) {

    //Extract the image URL 
    String? imageUrl = widget.data['image_url'];

    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: MyBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                 Align(
                  alignment: Alignment.topLeft,
                  child: 
                    IconButton(
                      onPressed: (){

                        Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(pageBuilder: 
                          (context, animation, secondaryAnimation) => const Homepage(initialIndex: 3,),
                          transitionDuration: Duration.zero,
                          ),
                          (route) => false,  
                        );
                      },
                      icon: Icon(Icons.arrow_back_ios_new_outlined, color: primaryColor,),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                 ),
            
                //You're a...
                Center(
                  child: Text("You're ",
                    style: TextStyle(
                      fontSize: 30,
                      color: secondaryColor,
                      fontWeight: FontWeight.bold
                    ),),
                ),
                
                // =================================================
                //                    MBTI IMAGE 
                // =================================================

                SizedBox(height: 30,),

                if(imageUrl != null && imageUrl.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Container(
                        height: 200,
                        width: 200, // (Optional) Letak width kalau nak ia jadi petak/bulat sempurna
                        
                        // 1. HIASAN CONTAINER (Shadow & Border)
                        decoration: BoxDecoration(
                          color: Colors.white, // Warna background (penting jika image transparent/loading)
                          borderRadius: BorderRadius.circular(20), // Bucu bulat container
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2), // Warna bayang
                              blurRadius: 10,
                              offset: const Offset(0, 5), // Bayang turun sikit ke bawah
                            ),
                          ],
                          // Kalau nak border, uncomment bawah ni:
                          // border: Border.all(color: primaryColor, width: 2), 
                        ),

                        // 2. POTONG GAMBAR (Supaya tak terkeluar dari bucu bulat container)
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20), // Mesti sama dengan Container atas
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover, // PENTING: Bagi gambar penuhkan ruang container
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                            },
                          ),
                        ),
                      ),
                    ),

                    Center(
                      child: Text(
                          widget.data['title'] ?? "The Personality",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                    ),

                    SizedBox(height: 20,),

                // --- THE MAIN CARD ---
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        widget.mbtiCode, 
                        style: TextStyle(
                          fontSize: 50, 
                          fontWeight: FontWeight.bold, 
                          color: primaryColor,
                          letterSpacing: 2.0
                        ),
                      ),

                      //Maksud each letter tu apa 
                      SizedBox(height: 10),
                      _buildTraitRow(),

                      Divider(height: 30),
                      Text(
                        widget.data['description'] ?? "Description loading...",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
        
                SizedBox(height: 20),

                // -- ACADEMIC PATH --

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Educational Style", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                      SizedBox(height: 5),
                      Text(widget.data['educational_style'] ?? "Not available", style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),

                //What kind of path they should pursue


                SizedBox(height: 20),
        
                // --- STRENGTHS SECTION ---
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Key Strengths", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                      SizedBox(height: 5),
                      Text(widget.data['strengths'] ?? "Not available", style: TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
        
                SizedBox(height: 40),
        
                // --- BUTTON TO START PHASE 2 (CAREER QUIZ) ---
                ElevatedButton.icon(
                  icon: Icon(Icons.person, color: Colors.white),
                  label: Text("View other personality", 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const PersonalityLibraryScreen()
                    ));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //--- 3. THE LETTER DESCRIPTION ---
  Widget _buildTraitRow() {
    // Split the string e.g."ENFP" into list ['E', 'N', 'F', 'P']
    List<String> letters = widget.mbtiCode.split(''); 

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Spreads them out nicely
      children: letters.map((letter) {
        return Column(
          children: [

            // The Big Letter Bubble
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 8),
            
            // The Definition Text (e.g. "Intuitive")
            Text(
              traitDefinitions[letter] ?? "", // Look up the word in our map
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
          ],
        );
      }).toList(),
    );
  }
}