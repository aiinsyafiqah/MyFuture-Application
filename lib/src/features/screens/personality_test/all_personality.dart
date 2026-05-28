import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:myfuture_application/src/utils/theme/colors.dart';

class PersonalityLibraryScreen extends StatefulWidget {
  const PersonalityLibraryScreen({super.key});

  @override
  State<PersonalityLibraryScreen> createState() => _PersonalityLibraryScreenState();
}

class _PersonalityLibraryScreenState extends State<PersonalityLibraryScreen> {
  
  // Kita dah tak perlukan List manual tadi. Kita tarik direct.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
        title: const Text("All Personality Types", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: primaryColor,
        // Kita buang bahagian 'bottom: TabBar(...)'
      ),

        body: 
            StreamBuilder<QuerySnapshot>(
              // 1. TUKAR 'mbti_data' KE NAMA COLLECTION MBTI AWAK
              stream: FirebaseFirestore.instance.collection('mbti_results').snapshots(), 
              builder: (context, snapshot) {
                
                // Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error / Empty State
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No MBTI data found."));
                }

                // Ada Data
                final docs = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    // Ambil data bagi setiap dokumen
                    var data = docs[index].data() as Map<String, dynamic>;
                    
                    // Kita pass document ID sekali (sebab selalunya ID tu adalah "INTJ", "ESFJ")
                    String docID = docs[index].id; 
                    
                    return _buildMbtiCard(docID, data);
                  },
                );
              },
            ),
        );
  }

  // --- WIDGET CARD UNTUK MBTI ---
  Widget _buildMbtiCard(String id, Map<String, dynamic> data) {
    // 3. PASTIKAN KEY ('title', 'description') SAMA DENGAN DATABASE AWAK
    String displayTitle = data['id'] ?? id; // Kalau takde title, guna ID (INTJ)
    String displayDesc = data['description'] ?? "No description";
    String displayImage = data['image_url'] ?? "";

    return GestureDetector(
      onTap: () {
        // Navigasi ke detail page (optional)
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, spreadRadius: 2)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // --- BAHAGIAN GAMBAR ---
            Container(
              height: 70, // Saiz gambar
              width: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.1), // Background pudar kalau gambar loading
              ),
              child: ClipOval(
                // 2. CHECK: ADA URL TAK?
                child: displayImage.isNotEmpty 
                  ? Image.network(
                      displayImage,
                      fit: BoxFit.cover, // Penuhkan bulatan
                      // Tunjuk loading pusing-pusing masa tengah tarik internet
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                      // Kalau link rosak/error, tunjuk icon orang
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, color: primaryColor, size: 30);
                      },
                    )
                  : Center( // Kalau URL kosong, tunjuk Text ID (INTJ) macam asal
                      child: Text(
                        id, 
                        style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16),
                      ),
                    ),
              ),
            ),
            // -----------------------

            const SizedBox(height: 10),
            
            // Nama (The Architect)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                displayTitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            
            const SizedBox(height: 5),
            
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                displayDesc,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}