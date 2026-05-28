import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class CareerPathwaysScreen extends StatefulWidget {
  final String jobTitle;
  
  const CareerPathwaysScreen({super.key, required this.jobTitle});

  @override
  State<CareerPathwaysScreen> createState() => _CareerPathwaysScreenState();
}

class _CareerPathwaysScreenState extends State<CareerPathwaysScreen> {
  String currentMbti = ""; 
  bool isLoading = true;
  Map<String, dynamic>? careerData;
  
  // 1. ADD THIS VARIABLE TO STORE THE REAL DATA
  List<Map<String, dynamic>> fullUniversityList = []; 
  
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      // A. Fetch User Data
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          currentMbti = userDoc.data()?['mbti_type'] ?? userDoc.data()?['riasec_code'] ?? "";
        }
      }

      // B. Fetch Career Data
      var pathwayDoc = await FirebaseFirestore.instance
          .collection('career_lists')
          .doc(widget.jobTitle)
          .get();

      if (pathwayDoc.exists) {
        Map<String, dynamic> data = pathwayDoc.data() as Map<String, dynamic>;
        careerData = data;

        // --- C. FETCH UNIVERSITY DETAILS (THE MISSING PART) ---
        List<dynamic> uniNames = data['related_unis'] ?? [];
        List<Map<String, dynamic>> tempUniList = [];

        print("DEBUG: Found these uni names in career_list: $uniNames");

        // 2. Loop through every Name and SEARCH for it
        if (uniNames.isNotEmpty) {
          for (String uniName in uniNames) {
            try {
              // 🔍 SEARCH: Find the document where the 'name' field matches 'USM'
              var querySnapshot = await FirebaseFirestore.instance
                  .collection('universities') 
                  .where('acronym', isEqualTo: uniName) // This checks the FIELD 'name'
                  .limit(1) // We only need the first match
                  .get();
              
              if (querySnapshot.docs.isNotEmpty) {
                // Get the first matching document
                var uniDoc = querySnapshot.docs.first;
                tempUniList.add(uniDoc.data());
              } else {
                print("No university found with name: $uniName");
              }
            } catch (e) {
              print("Error searching for $uniName: $e");
            }
          }
        }
        
        // 3. Save the result so the UI can use it
        fullUniversityList = tempUniList; 
      }

      setState(() => isLoading = false);
    } catch (e) {
      print("Error loading data: $e");
      setState(() => isLoading = false);
    }
  }


@override
  Widget build(BuildContext context) {
    //check if the currentMbti tu ada S ke tak 
    String learnerType = currentMbti.contains('S')
      ? "hands-on learner"
      : "theory learner";

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    bool hasTakenTest = currentMbti.isNotEmpty;
    String userStyle = currentMbti.length > 1 ? currentMbti[1] : '';
    
    // Sort logic
    List<dynamic> rawPathways = careerData != null && careerData!['pathways'] != null 
        ? careerData!['pathways'] : [];
    List<dynamic> sortedPathways = List.from(rawPathways);
    if (hasTakenTest) {
      sortedPathways.sort((a, b) {
        bool isAMatch = a['recommended_mbti'] == userStyle;
        bool isBMatch = b['recommended_mbti'] == userStyle;
        if (isAMatch && !isBMatch) return -1;
        if (!isAMatch && isBMatch) return 1;
        return 0;
      });
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView( // Added ScrollView to prevent overflow on small screens
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              //Go back to career list page 
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0), // Jarak tepi sikit
                child: Stack(
                  alignment: Alignment.center, // Pastikan semua benda align center dulu
                  children: [
                    
                    // 1. Back Button (Duduk di Kiri)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context); // Fungsi untuk back
                        },
                        icon: const Icon(Icons.arrow_back_ios, size: 24),
                        padding: EdgeInsets.zero, // Hilangkan padding extra supaya rapat tepi
                        constraints: const BoxConstraints(), // Kecilkan ruang button
                      ),
                    ),
                    
                    const SizedBox(height: 20,),
                    // 2. Tajuk (Duduk di Tengah)
                    Text(
                      "Becoming\n${widget.jobTitle}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              if (hasTakenTest)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    "You are $currentMbti, a $learnerType",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              
              const SizedBox(height: 20),
          
              // --- 2. SLIDESHOW AREA (REDUCED HEIGHT) ---
              // Changed from 0.65 to 0.55 so it doesn't take too much space
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45, 
                child: sortedPathways.isNotEmpty 
                ? PageView.builder(
                    controller: _pageController,
                    itemCount: sortedPathways.length,
                    itemBuilder: (context, index) {
                      var path = sortedPathways[index];
                      bool isMatch = hasTakenTest && (path['recommended_mbti'] == userStyle);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0), // Consistent Gap
                        child: _buildPathwayCard(
                          title: path['title'] ?? "Pathway Title",
                          duration: path['duration'],
                          reason: path['reason'],
                          isRecommended: isMatch,
                          steps: List<Map<String, dynamic>>.from(path['steps'] ?? []),
                        ),
                      );
                    },
                  )
                : const Center(child: Text("No pathway data")),
              ),

              const SizedBox(height: 25), 

              // --- 3. UNIVERSITIES SECTION ---
              if (fullUniversityList.isNotEmpty) ...[
                 // ALIGNMENT FIX: Added left padding (25.0) to match the visual card edge
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 25.0), 
                   child: Align(
                     alignment: Alignment.centerLeft,
                     child: Text("Universities for ${widget.jobTitle}", 
                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   ),
                 ),
                 
                 const SizedBox(height: 10),

                 SizedBox(
                   height: 160, // Fixed height for the horizontal list
                   child: ListView.builder(
                     // Add padding to the start of the list so the first card aligns with the title
                     padding: const EdgeInsets.only(left: 25, right: 25),
                     scrollDirection: Axis.horizontal,
                     itemCount: fullUniversityList.length,
                     itemBuilder: (context, index) {
                       var uni = fullUniversityList[index];
                       return _buildUniCard(uni);
                     },
                   ),
                 ),
                 const SizedBox(height: 20),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS (NOW INSIDE THE CLASS PROPERLY) ---

  Widget _buildUniCard(Map<String, dynamic> uniData) {
    return GestureDetector(
      onTap: () async {
        String universityUrl;

        // 1. Get the Faculty Key from the Career Data (loaded in _loadAllData)
        // defaulting to the job title if no specific key is set.
        String searchKey = careerData?['faculty_key'] ?? widget.jobTitle;

        // 2. Get the map of faculty links from the University Data
        Map<String, dynamic>? facultyLinks = uniData['faculty_urls'];
        String generalUrl = uniData['general_url'] ?? "";

        // 3. Logic to find the correct link
        if (facultyLinks != null && facultyLinks.containsKey(searchKey)) {
          // Case A: Specific link found for this key (e.g., "Accounting")
          universityUrl = facultyLinks[searchKey];
          print("Found specific link for $searchKey: $universityUrl");
        } else {
          // Case B: No specific link found, fallback to general homepage
          universityUrl = generalUrl;
          print("No specific link for $searchKey. Using general: $generalUrl");
        }

        // 4. Launch the URL
        final Uri uri = Uri.parse(universityUrl);
        if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not launch $universityUrl")),
          );
        }
      },
      child: Container(
        // ... (rest of your container styling remains the same)
        width: 140,
        margin: const EdgeInsets.only(right: 15, bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                  image: uniData['logo_url'] != null 
                    ? DecorationImage(image: NetworkImage(uniData['logo_url']), fit: BoxFit.cover)
                    : null
                ),
                child: uniData['logo_url'] == null 
                  ? const Icon(Icons.school, color: Colors.blue) 
                  : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              uniData['uni_name'] ?? "Uni Name",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

    // --- HELPER WIDGET: CARD ---
  // --- HELPER WIDGET: CARD (UPDATED) ---
  Widget _buildPathwayCard({
    required String title,
    required String duration,
    required String? reason,
    required bool isRecommended,
    required List<Map<String, dynamic>> steps,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          margin: const EdgeInsets.only(bottom: 10), 
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isRecommended 
              ? Border.all(color: Colors.green, width: 2.5) 
              : Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: SingleChildScrollView( 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10), 
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(duration, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                
                if (isRecommended && reason != null)
                   Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: Text("💡 $reason", style: TextStyle(fontSize: 13, color: Colors.green[700], fontStyle: FontStyle.italic)),
                   ),
                
                const SizedBox(height: 25),
        
                // Timeline Steps Loop
                ...steps.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Map step = entry.value;
                  bool isLast = idx == steps.length - 1;
                  
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 18, height: 18,
                              decoration: BoxDecoration(
                                color: step['isFinal'] == true ? Colors.redAccent : Colors.amber,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]
                              ),
                            ),
                            if (!isLast)
                              Expanded(child: Container(width: 2, color: Colors.black87)),
                          ],
                        ),
                        const SizedBox(width: 15),
                        
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 25.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(step['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                    
                                    // --- UBAH BAHAGIAN INI ---
                                    // Hanya tunjuk kotak biru jika time TIDAK NULL dan TIDAK KOSONG
                                    if (step['time'] != null && step['time'].toString().trim().isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                                        child: Text(step['time'], style: TextStyle(fontSize: 11, color: Colors.blue[700], fontWeight: FontWeight.bold)),
                                      ),
                                    // -------------------------
                                  ],
                                ),
                                if (step['desc'] != null && step['desc'].isNotEmpty)
                                  Text(step['desc'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                
                                if (step['note'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
                                        const SizedBox(width: 5),
                                        Expanded(child: Text(step['note'], style: const TextStyle(fontSize: 12, color: Colors.grey))),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),

        // Flag "Recommended"
        if (isRecommended)
          Positioned(
            top: 0,
            right: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.thumb_up, color: Colors.white, size: 14),
                  SizedBox(width: 5),
                  Text("Recommended for you", 
                  style: TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 15)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}