import 'package:flutter/material.dart';
import 'package:myfuture_application/models/mbti_questions_model.dart';
import 'package:myfuture_application/services/database_services.dart';
import 'package:myfuture_application/src/features/screens/homepage/homepage.dart';
import 'package:myfuture_application/src/features/screens/personality_test/loadingresult_page.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // 1. State Variables
  List<Question> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  double _currentSliderValue = 3.0; // Default to 'Neutral'

  // 2. Score Tracker
  Map<String, int> _scores = {
    'EI': 0,
    'SN': 0,
    'TF': 0,
    'JP': 0,
  };

  // 3. Store raw answers
  Map<int, double> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() async {
    DatabaseService db = DatabaseService();
    List<Question> fetchedQuestions = await db.getQuestions();

    if (!mounted) return;

    setState(() {
      _questions = fetchedQuestions;
      _isLoading = false;
    });
  }

  void _nextQuestion() {
    _userAnswers[_currentIndex] = _currentSliderValue;

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _currentSliderValue = _userAnswers[_currentIndex] ?? 3.0;
      });
    } else {
      _finishQuiz();
    }
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _userAnswers[_currentIndex] = _currentSliderValue;
        _currentIndex--;
        _currentSliderValue = _userAnswers[_currentIndex] ?? 3.0;
      });
    }
  }

  void _finishQuiz() {
    _userAnswers[_currentIndex] = _currentSliderValue;
    _scores = {'EI': 0, 'SN': 0, 'TF': 0, 'JP': 0};
    Map<String, int> questionCounts = {'EI': 0, 'SN': 0, 'TF': 0, 'JP': 0};

    _userAnswers.forEach((index, value) {
      Question q = _questions[index];
      double points = (q.direction == 1) ? value : (6 - value);
      _scores[q.dimension] = (_scores[q.dimension] ?? 0) + points.toInt();
      questionCounts[q.dimension] = (questionCounts[q.dimension] ?? 0) + 1;
    });

    String p1 = (_scores['EI']! >= (questionCounts['EI']! * 3)) ? 'E' : 'I';
    String p2 = (_scores['SN']! >= (questionCounts['SN']! * 3)) ? 'S' : 'N';
    String p3 = (_scores['TF']! >= (questionCounts['TF']! * 3)) ? 'T' : 'F';
    String p4 = (_scores['JP']! >= (questionCounts['JP']! * 3)) ? 'J' : 'P';

    String finalResult = "$p1$p2$p3$p4";

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoadingResultPage(
                mbtiCode: finalResult, isNewResult: true)));
  }

  String _getEmojiAsset(double value) {
    if (value == 1.0) return 'assets/emojis/strongly_disagree.png';
    if (value == 2.0) return 'assets/emojis/disagree.png';
    if (value == 3.0) return 'assets/emojis/neutral.png';
    if (value == 4.0) return 'assets/emojis/agree.png';
    return 'assets/emojis/strongly_agree.png';
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Quit Quiz",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            content: const Text(
                'Are you sure you want to quit? Your progress will be lost.'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            actionsAlignment: MainAxisAlignment.center,
            actions: <Widget>[
              // Stay Button
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12)),
                child: const Text('Stay'),
              ),
              // Quit Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Homepage(initialIndex: 3)),
                      (route) => false);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12)),
                child: const Text('Quit'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    Question q = _questions[_currentIndex];

    // Guna LayoutBuilder untuk tahu saiz skrin sebenar
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Kira tinggi skrin yang tersedia
              double screenHeight = constraints.maxHeight;
              double screenWidth = constraints.maxWidth;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
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
                          icon: Icon(Icons.arrow_back_ios_new_outlined,
                              color: primaryColor),
                        ),
                        Expanded(
                          child: Text(
                            'PERSONALITY TEST',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05, // Font responsif
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    // Progress Text
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      "Question ${_currentIndex + 1} of ${_questions.length}",
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),

                    // Ruang fleksibel atas soalan
                    Spacer(flex: 1),

                    // --- THE QUESTION ---
                    // Guna Flexible supaya text boleh wrap cantik
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        q.text,
                        style: TextStyle(
                          fontSize: screenWidth * 0.06, // Font ikut lebar phone
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 4, // Hadkan baris
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Ruang fleksibel bawah soalan
                    Spacer(flex: 1),

                    // --- THE EMOJI (RESPONSIF) ---
                    // Guna Expanded supaya emoji isi ruang yang ada sahaja
                    Expanded(
                      flex: 4, // Bagi ruang lebih sikit kat emoji
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Image.asset(
                          _getEmojiAsset(_currentSliderValue),
                          key: ValueKey<double>(_currentSliderValue),
                          fit: BoxFit.contain, // Pastikan tak kena potong
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // --- THE SLIDER ---
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: primaryColor,
                        inactiveTrackColor: Colors.grey[300],
                        trackHeight: 6.0,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                        thumbColor: primaryColor,
                        overlayColor: primaryColor.withOpacity(0.2),
                        activeTickMarkColor: Colors.transparent,
                        inactiveTickMarkColor: Colors.transparent,
                      ),
                      child: Slider(
                        value: _currentSliderValue,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: _currentSliderValue.round().toString(),
                        onChanged: (val) {
                          setState(() {
                            _currentSliderValue = val;
                          });
                        },
                      ),
                    ),

                    // Labels (Disagree <-> Agree)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Strongly\nDisagree",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          const Text("Neutral",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          const Text("Strongly\nAgree",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ],
                      ),
                    ),

                    Spacer(flex: 1),

                    // --- BUTTONS ---
                    // Letak padding bawah sikit supaya tak rapat sangat dengan bucu phone
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          // Back Button
                          if (_currentIndex > 0)
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: primaryColor, width: 2),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: _prevQuestion,
                                child: Text("BACK",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor)),
                              ),
                            ),

                          if (_currentIndex > 0) const SizedBox(width: 16),

                          // Next Button
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: _nextQuestion,
                              child: Text(
                                _currentIndex == _questions.length - 1
                                    ? "FINISH"
                                    : "NEXT",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}