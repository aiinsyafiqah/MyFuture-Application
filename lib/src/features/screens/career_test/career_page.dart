import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myfuture_application/src/features/screens/pathways/final_result.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart';

class CareerPageContent extends StatefulWidget {
  const CareerPageContent({super.key});

  @override
  State<CareerPageContent> createState() => _CareerPageContentState();
}

class _CareerPageContentState extends State<CareerPageContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('C A R E E R',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // --- 2. SEARCH BAR ---
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search career (e.g. Accountant)...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: primaryColor),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: primaryColor),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: backgroundColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: backgroundColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
                onChanged: (value) {
                  setState(() {}); 
                },
              ),

              const SizedBox(height: 20),

              // --- 3. CAREER LIST CONTAINER ---
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('career_lists').snapshots(),
                  builder: (context, snapshot) {
                    
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No careers found."));
                    }

                    var docs = snapshot.data!.docs;
                    var filteredDocs = docs.where((doc) {
                      String title = (doc['id'] ?? doc.id).toString().toLowerCase();
                      String search = _searchController.text.toLowerCase();
                      return title.contains(search);
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return const Center(child: Text("No matching careers found."));
                    }

                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        var data = filteredDocs[index].data() as Map<String, dynamic>;
                        
                        // Ambil Data
                        String title = data['id'] ?? "Unknown Career";
                        String salary = data['salary'] ?? "Not specified";
                        
                        // AMBIL DOC ID (PENTING UNTUK UPDATE)
                        String docId = filteredDocs[index].id;

                        // Return Card Widget (Kita pass docId sekali)
                        return _buildCareerCard(context, title, salary, docId);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGET: THE CAREER CARD ---
  // Tambah parameter 'docId' di sini
  Widget _buildCareerCard(BuildContext context, String title, String salary, String docId) {
    return GestureDetector(
      onTap: () {
        // --- 1. LOGIC UPDATE VIEW COUNT ---
        FirebaseFirestore.instance
            .collection('career_lists')
            .doc(docId) // Guna ID document yang sebenar
            .update({
              'view_count': FieldValue.increment(1), 
            })
            .catchError((error) {
              // Kalau field view_count tak wujud lagi, kita create field baru
               FirebaseFirestore.instance
                  .collection('career_lists')
                  .doc(docId)
                  .set({'view_count': 1}, SetOptions(merge: true));
            });

        // --- 2. NAVIGATE ---
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CareerPathwaysScreen(jobTitle: title)
          )
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15), 
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                      "Starting salary", 
                      style: TextStyle(
                        fontSize: 13,  
                        fontWeight: FontWeight.w700)
                    ),
                  
                   const SizedBox(height: 5),
                   
                 Text(
                      "RM $salary", 
                      style: TextStyle(
                        fontSize: 13, 
                        color: Colors.green[800], 
                        fontWeight: FontWeight.bold)
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}