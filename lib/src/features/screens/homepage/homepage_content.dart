import 'dart:async'; // <--- WAJIB ADA UNTUK TIMER
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfuture_application/src/features/controllers/bottomNavigationBar.dart';
import 'package:myfuture_application/src/features/screens/career_test/career_page.dart';
import 'package:myfuture_application/src/features/screens/career_test/career_result_page.dart';
import 'package:myfuture_application/src/features/screens/slide_menu/notification_list.dart'; // Pastikan path ini betul
import 'package:myfuture_application/src/features/screens/slide_menu/slide_drawer.dart';
import 'package:myfuture_application/src/features/screens/personality_test/front_quiz_page.dart';
import 'package:myfuture_application/src/features/screens/personality_test/mbti_result_display.dart';
import 'package:myfuture_application/src/features/screens/personality_test/quiz_screen.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';
import 'package:myfuture_application/src/utils/widget_theme/banner_card.dart';
import 'package:myfuture_application/src/utils/widget_theme/calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomepageContent extends StatefulWidget {
  final VoidCallback onGoToCareer;
  const HomepageContent({
    super.key,
    required this.onGoToCareer});

  @override
  State<HomepageContent> createState() => _HomepageContentState();
}

class _HomepageContentState extends State<HomepageContent> {

  DateTime _selectedDate = DateTime.now();
  final user = FirebaseAuth.instance.currentUser!; 
  int _triggeredCount = 0;
  
  // --- 1. VARIABLE BARU UNTUK FIX KELIP-KELIP & TIMER ---
  Timer? _badgeTimer;
  late Future<Map<String, String>> _userDataFuture; 
  // -----------------------------------------------------

  @override
  void initState() {
    super.initState();
    
    // --- 2. INITIALIZE FUTURE SEKALI SAHAJA (FIX KELIP) ---
    _userDataFuture = _getUserProfile(); 
    // -----------------------------------------------------

    _checkTriggeredNotifications(); 
    
    // --- 3. TIMER UNTUK AUTO-CHECK BADGE SETIAP 1 SAAT ---
    _badgeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkTriggeredNotifications();
    });
  }

  @override
  void dispose() {
    // --- 4. MATIKAN TIMER (WAJIB) ---
    _badgeTimer?.cancel();
    super.dispose();
  }

  // --- LOGIC: Kira notification yang MASA DAH LEPAS ---
  Future<void> _checkTriggeredNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> rawList = prefs.getStringList('notification_history') ?? [];
    
    int count = 0;
    DateTime now = DateTime.now();

    for (String item in rawList) {
      // Pecahkan string guna '|||' (Logic Save dari Scholarships Page)
      List<String> parts = item.split('|||');
      
      if (parts.length >= 3) {
        String timeStr = parts[2]; // Ambil bahagian masa
        DateTime triggerTime = DateTime.tryParse(timeStr) ?? now;
        
        // Kalau masa dah lepas, kira 1
        if (triggerTime.isBefore(now)) {
          count++;
        }
      }
    }

    // Update UI hanya kalau nombor berubah (Supaya tak lag)
    if (mounted && count != _triggeredCount) {
      setState(() {
        _triggeredCount = count;
      });
    }
  }
  
  Future<void> _clearBadge() async {
    // Logic clear ni optional, kalau nak badge hilang bila tekan
    // Kita tak clear 'notification_history' (sebab user nak tengok list), 
    // tapi kita boleh set flag lain. Tapi untuk mudah, kita biarkan logic count jalan.
    // Atau kalau nak simple: Jangan buat apa-apa kat sini, biar user delete manual kat page list.
  }

  // _getUserProfile()
  Future<Map<String, String>> _getUserProfile() async{
    if (user != null){
      try{
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

        if(userDoc.exists){
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          return {
            'name': data['name'] ?? "Student",
            'mbti': data['mbti_type'] ?? "",
          };
        }
      }catch (e){
        print("Error fetching user data: $e");
      }
    }
    return{'name': "Student",'mbti':""};
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: backgroundColor,
            endDrawer: const SideMenuDrawer(),

            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      children: [


     
                      const SizedBox(height: 15),

                        // --- HEADER ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                          children: [
                            // 1. BAHAGIAN KIRI (TEKS)
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .snapshots(), // <--- Kita dengar perubahan database terus
                              builder: (context, snapshot) {
                                String displayName = "Hi, there!";
                                String subText = "Plan your future with us!";

                                if (snapshot.hasData && snapshot.data!.exists) {
                                  Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                                  // Ambil nama terkini dari database
                                  String name = data['name'] ?? "Friend";
                                  displayName = "Hi, $name !";
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: primaryColor,
                                      ),
                                    ),
                                    Text(
                                      subText,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: primaryColor.withOpacity(0.7),
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
      
                            // 2. BAHAGIAN KANAN (GROUP ICON)
                            Row(
                              children: [
                                // --- Notification Icon ---
                                GestureDetector(
                                  onTap: () async {
                                    // Navigate ke Notification Page
                                    // Pastikan nama class NotificationsPage betul
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context)=> const NotificationsPage())
                                    );
                                    
                                    // Lepas balik dari page list, check balik count
                                    _checkTriggeredNotifications();
                                  },
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        child: Icon(
                                          Icons.notifications,
                                          color: primaryColor,
                                          size: 30,
                                        ),
                                      ),
                                      
                                      // LOGIC BADGE MERAH
                                      if (_triggeredCount > 0) 
                                        Positioned(
                                          right: -3,
                                          top: -3,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '$_triggeredCount',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
      
                                const SizedBox(width: 10), 
      
                                // --- Menu Icon ---
                                Builder(
                                  builder: (context) {
                                    return GestureDetector(
                                      onTap: () {
                                        Scaffold.of(context).openEndDrawer();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(Icons.menu, color: primaryColor, size: 30),
                                      ),
                                    );
                                  }
                                )
                              ],
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 30),
                      
                      //  --- CALENDAR ---
                       CalendarStrip(
                        onDateSelected: (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                      ),
      
                      const SizedBox(height: 10),
      
                      // ====================================
                      // STREAM BUILDER (MBTI & CAREER)
                      // ====================================
                      const SizedBox(height: 20),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .snapshots(), 
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.exists) {
                            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

                            String userName = data['name'] ?? "You";
                            
                            // 1. Get MBTI Code
                            String? mbtiResult = data['mbti_type'];
                            
                            // 2. Get Career Code
                            String? careerResult = data['riasec_code']; 
      
                            return Column(
                              children: [
                                // --- MBTI SECTION ---
                                if (mbtiResult != null && mbtiResult.isNotEmpty) 
                                  MbtiImageLoader(
                                    mbtiCode: mbtiResult,
                                    userName: userName,)
                                else 
                                  PersonalityTestBanner(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizFrontPage()));
                                    }
                                  ),
                                
                                const SizedBox(height: 20),
      
                                // --- CAREER RESULT SECTION ---
                                if (careerResult != null && careerResult.isNotEmpty)
                                  CareerResultLoader(
                                    careerCode: careerResult,
                                    userName: userName,)
                                else
                                  GestureDetector(
                                    onTap: () {
                                       Navigator.push(context, MaterialPageRoute(builder: (context) => const CareerPageContent()));
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.work_outline, size: 40, color: primaryColor),
                                          const SizedBox(width: 15),
                                          const Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Discover Your Career", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              Text("Take the test to find out!", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                              ],
                            );
                          }
      
                          // Loading state
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// =====================================
//      1. MBTI IMAGE LOADER 
// =====================================
class MbtiImageLoader extends StatelessWidget {
  final String mbtiCode; 
  final String userName;

  const MbtiImageLoader({
    super.key, 
    required this.mbtiCode,
    required this.userName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('mbti_results')
          .doc(mbtiCode)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
        }

        String imageUrl = "";
        String eduStyle = "";
        Map<String, dynamic> fullData = {};

        if (snapshot.hasData && snapshot.data!.exists) {
          fullData = snapshot.data!.data() as Map<String, dynamic>;
          imageUrl = fullData['image_url'] ?? "";
          eduStyle = fullData['educational_style'] ?? "";
        }

        return _buildMbtiResultCard(context, mbtiCode, imageUrl, eduStyle, fullData);
      },
    );
  }

  Widget _buildMbtiResultCard(BuildContext context, String mbtiType, String imageUrl, String eduStyle, Map<String,dynamic> fullData) {
    return GestureDetector(
      onTap: () {
        // PENTING: Guna CareerResultDisplayPage (tapi untuk MBTI mungkin awak ada page lain? 
        // Saya ikut kod asal awak yg point ke sini)
        Navigator.push(
          context, 
          // Note: Pastikan page ni boleh handle MBTI code juga kalau awak share page
          MaterialPageRoute(builder: (context) => MbtiResultDisplayPage(
            mbtiCode: mbtiCode, 
            data: fullData,
            isNewResult: false,))
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Padding(
            padding: const EdgeInsets.only(bottom: 10.0, left: 5.0), 
            child: Text(
              "✨ $userName's Unique Personality",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Circular Image
                Container(
                  height: 150, width: 150, // Kecilkan sikit supaya balance
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), 
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(
                    child: imageUrl.isNotEmpty 
                      ? Image.network(
                          imageUrl, 
                          fit: BoxFit.cover,
                          errorBuilder: (c,e,s) => const Icon(Icons.person, color: Colors.white, size: 50),
                        )
                      : const Icon(Icons.person, color: Colors.white, size: 50),
                  ),
                ),
                const SizedBox(height: 10),
                Text(mbtiType, 
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 15,),
                Text(eduStyle, 
                  textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 16)
                ),
                const SizedBox(height: 10,),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context)=> QuizScreen()));
                    },
                    child: Text("Retake Quiz",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white
                    ),),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// =====================================
//      2. CAREER RESULT LOADER (BARU)
// =====================================
// Ini widget baru untuk tunjuk result career tanpa gambar
class CareerResultLoader extends StatelessWidget {
  final String careerCode; // e.g., "ASE"
  final String userName;

  const CareerResultLoader({
    super.key, 
    required this.careerCode,
    required this.userName});

  @override
  Widget build(BuildContext context) {
    // Ambil huruf pertama (Primary) untuk dapatkan nama penuh (e.g. A -> Artistic)
    String primaryLetter = careerCode.isNotEmpty ? careerCode[0] : "";

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('career_results') // Collection career results
          .doc(primaryLetter) // Cari based on huruf pertama
          .get(),
      builder: (context, snapshot) {
        
        String primaryName = "Unknown"; // Default
        
        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          primaryName = data['name'] ?? "Unknown";
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0, left: 5.0),
              child: Text(
                "✨ $userName's Career Path",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            GestureDetector(
              onTap: () {
                // Pergi ke detail page
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => CareerResultDisplayPage(
                    topCode: careerCode,
                    isNewResult: false,))
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: primaryColor, // Kad warna putih
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                  border: Border.all(color: primaryColor.withOpacity(0.2)), // Border nipis warna tema
                ),
                child: Row(
                  children: [
                    // Icon Box Sebelah Kiri
                    Container(
                      height: 60, width: 60,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 159, 179, 238),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(Icons.work_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 20),
                    
                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            " $primaryName",
                            style: TextStyle(
                              fontSize: 18, 
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow Icon
                    Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.white)
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}