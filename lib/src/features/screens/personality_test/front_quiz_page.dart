import 'package:flutter/material.dart';
import 'package:myfuture_application/src/features/screens/career_test/career_quiz_screen.dart';
import 'package:myfuture_application/src/features/screens/personality_test/quiz_screen.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

// model class 
class QuizOption {
  final String title;
  final String description;
  final Color color;
  final String imagePath;
  final Widget destinationPage;

  QuizOption({
    required this.title,
    required this.description,
    required this.color,
    required this.imagePath,
    required this.destinationPage,
  });
}

class QuizFrontPage extends StatefulWidget {
  const QuizFrontPage({super.key});

  @override
  State<QuizFrontPage> createState() => _QuizFrontPageState();
}

class _QuizFrontPageState extends State<QuizFrontPage> {
  //controller
  final PageController _pageController = PageController(viewportFraction: 0.85); // Tukar 0.75 ke 0.85 supaya kad nampak lebar sikit kat phone kecik

  //which card is the default 
  int _currentIndex = 0;

  //define quiz 
  final List<QuizOption> _quizzes = [
    // --- MBTI QUIZ ---
    QuizOption(
        title: "MBTI Quiz",
        description: "Discover your personality and recommended pathways",
        color: const Color.fromARGB(255, 228, 159, 182),
        imagePath: "assets/images/personality_quiz.jpeg",
        destinationPage: QuizScreen()),

    // --- CAREER QUIZ ---
    QuizOption(
        title: "Career Quiz",
        description: "Find the job path that suits your strength",
        color: const Color.fromARGB(255, 126, 136, 238),
        imagePath: "assets/images/career_quiz.jpeg",
        destinationPage: CareerQuizScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    // 1. DAPATKAN SAIZ SKRIN
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column( // Buang Padding kat sini supaya layout lebih bebas
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            SizedBox(height: screenHeight * 0.02), // Jarak dinamik (2% dari tinggi skrin)

            // --- HEADER SECTION (Dengan Padding Sendiri) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  // --- pick a card, play quiz ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Guna Flexible supaya text tak overflow kalau skrin kecik sangat
                      Flexible(
                        child: Text(
                          'Pick a card \nto play quiz',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            // 2. FONT SIZE DINAMIK (Ikut lebar skrin)
                            fontSize: screenWidth * 0.08, // Contoh: 8% dari lebar skrin
                            fontWeight: FontWeight.bold,
                            height: 1.2, // Rapatkan sikit jarak baris
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // --- description ---
                  Text(
                    'Select the quiz category to know yourself better!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14, // Kecilkan sikit standard size
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),

            // -- SLIDER SECTION -- 
            Expanded(
              child: PageView.builder(
                  controller: _pageController,
                  itemCount: _quizzes.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildQuizCard(_quizzes[index], screenHeight);
                  }),
            ),

            //-- BOTTOM BUTTON -- 
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 10, 30, 30), // Kurangkan padding atas
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  _quizzes[_currentIndex].destinationPage));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5, // Tambah shadow sikit bagi lawa
                    ),
                    child: const Text(
                      'Play Quiz',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  // INDIVIDUAL CARD QUIZ
  Widget _buildQuizCard(QuizOption quiz, double screenHeight) {
    return Container(
      // 3. KURANGKAN MARGIN
      // Guna margin kiri kanan sikit je, atas bawah bagi ruang sikit
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      
      decoration: BoxDecoration(
        color: quiz.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Padding dalam kad
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TITLE
            Text(
              quiz.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22, // Besar sikit title dalam kad
                  color: Colors.white),
            ),

            const SizedBox(height: 10),

            // 4. GAMBAR JADI RESPONSIF (Flexible/Expanded)
            // Ini paling penting. Gambar akan mengecil kalau skrin pendek.
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // Hiasan background bulat pudar
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(15),
                child: Image.asset(
                  quiz.imagePath,
                  fit: BoxFit.contain, // Pastikan gambar tak kena potong
                ),
              ),
            ),

            const SizedBox(height: 15),

            // DESCRIPTION
            Text(
              quiz.description,
              textAlign: TextAlign.center,
              maxLines: 3, // Hadkan baris supaya tak overflow
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                height: 1.3,
              ),
            )
          ],
        ),
      ),
    );
  }
}