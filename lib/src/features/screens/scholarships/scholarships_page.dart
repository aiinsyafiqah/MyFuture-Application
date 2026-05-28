import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myfuture_application/src/features/screens/scholarships/scholarship_filter.dart'; // Pastikan path ni betul
import 'package:myfuture_application/src/utils/theme/colors.dart'; // Pastikan path ni betul
import 'package:myfuture_application/src/features/controllers/notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ScholarshipsPageContent extends StatefulWidget {
  const ScholarshipsPageContent({super.key});

  @override
  State<ScholarshipsPageContent> createState() => _ScholarshipsPageContentState();
}

class _ScholarshipsPageContentState extends State<ScholarshipsPageContent> {
  final TextEditingController _searchController = TextEditingController();

  // STATE VARIABLES
  bool _showSavedOnly = false;
  String _selectedSpm = "All Results"; 
  String _selectedType = "All Types"; 
  
  // Set untuk simpan ID scholarship yang user save
  Set<String> _savedScholarshipIds = {}; 

  // --- VARIABLE PENTING: Untuk elak saved list hilang ---
  bool _isLoadingSaved = true; 

  @override
  void initState() {
    super.initState();
    // 2. Baca saved list dari memori phone
    _loadSavedIds(); 
  }



  // --- FIX: BACA DARI MEMORI & UPDATE LOADING STATUS ---
  Future<void> _loadSavedIds() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedList = prefs.getStringList('saved_scholarships') ?? [];
    
    if (mounted) {
      setState(() {
        _savedScholarshipIds = savedList.toSet();
        _isLoadingSaved = false; // <--- Bagitahu UI dah siap baca
      });
    }
  }

  // --- SIMPAN KE MEMORI ---
  Future<void> _toggleSave(String docId) async {
    setState(() {
      if (_savedScholarshipIds.contains(docId)) {
        _savedScholarshipIds.remove(docId);
      } else {
        _savedScholarshipIds.add(docId);
      }
    });

    // Simpan perubahan ke dalam phone supaya tak hilang bila restart
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_scholarships', _savedScholarshipIds.toList());
  }

  // --- HANDLE TEKAN BUTTON SAVE ---
  Future<void> _handleSave(String docId, Map<String, dynamic> data) async {
    // 1. Save dulu
    await _toggleSave(docId);

    // 2. Kalau user SAVE (bukan unsave), simpan history & schedule notification
    if (_savedScholarshipIds.contains(docId)) {
      try {
        final prefs = await SharedPreferences.getInstance();
        List<String> savedNotifications = prefs.getStringList('notification_history') ?? [];
        DateTime triggerTime = DateTime.now();
        String dataToSave = "${data['title'] ?? 'Scholarship'}|||Saved: Don't forget to apply!|||${triggerTime.toIso8601String()}";
        savedNotifications.add(dataToSave);
        await prefs.setStringList('notification_history', savedNotifications);

        // --- NOTIFICATION LOGIC ---
        String scholarshipName = data['title'] ?? 'Scholarship';
        DateTime? deadlineDate;
        if (data['deadline'] != null) {
          if (data['deadline'] is Timestamp) {
            deadlineDate = (data['deadline'] as Timestamp).toDate();
          } else if (data['deadline'] is String && data['deadline'] != 'N/A') {
            try {
              deadlineDate = DateFormat('dd MMM yyyy').parse(data['deadline']);
            } catch (e) {
              deadlineDate = null;
            }
          }
        }
        if (data['deadline'] == null || data['deadline'] == 'N/A') {
          deadlineDate = null;
        }
        await NotificationService.setScholarshipReminder(scholarshipName, deadlineDate);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Scholarship saved! We'll remind you later."),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e, st) {
        print('Error saving history: $e\n$st');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Saved locally."),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterModal(
          currentSpmResult: _selectedSpm, 
          currentType: _selectedType,
          onApply: (newSpm, newType) {
            setState(() {
              _selectedSpm = newSpm; 
              _selectedType = newType;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- 1. BLOCKING: Tunjuk loading kalau belum siap baca saved list ---
    // Ini penting supaya user tak nampak list "kosong" sebelum data load
    if (_isLoadingSaved) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor, 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('S C H O L A R S H I P S', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                ],
              ),
              const SizedBox(height: 20),
              
              // SEARCH & FILTER
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search scholarships...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.search, color: primaryColor),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(icon: Icon(Icons.clear, color: primaryColor), onPressed: () => setState(() => _searchController.clear()))
                            : null,
                        filled: true, fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(12)),
                    child: IconButton(icon: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 28), onPressed: _showFilterSheet),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // TABS & CHIPS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabButton("All List", !_showSavedOnly),
                    const SizedBox(width: 10),
                    _buildTabButton("Saved", _showSavedOnly),
                    
                    if (_selectedSpm != "All Results") 
                      _buildFilterChip(_selectedSpm, () => setState(() => _selectedSpm = "All Results")),

                    if (_selectedType != "All Types") 
                      _buildFilterChip(_selectedType, () => setState(() => _selectedType = "All Types")),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // STREAM BUILDER
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('scholarships').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (snapshot.hasError) return const Center(child: Text("Error loading data"));

                    final docs = snapshot.data?.docs ?? [];
                    
                    final filteredDocs = docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final id = doc.id;

                      String name = (data['title'] ?? '').toString().toLowerCase();
                      String provider = (data['provider'] ?? '').toString().toLowerCase();
                      String type = (data['category'] ?? '').toString(); 
                      String spmReq = (data['spm_result'] ?? '').toString(); 

                      String searchText = _searchController.text.toLowerCase();

                      bool matchesSearch = name.contains(searchText) || provider.contains(searchText);
                      bool matchesSaved = !_showSavedOnly || _savedScholarshipIds.contains(id);
                      
                      // Filter Checks
                      bool matchesType = _selectedType == "All Types" || type == _selectedType;
                      bool matchesSpm = _selectedSpm == "All Results" || spmReq == _selectedSpm;

                      return matchesSearch && matchesSaved && matchesType && matchesSpm;
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off, size: 50, color: Colors.grey[400]), const SizedBox(height: 10), Text("No scholarships found", style: TextStyle(color: Colors.grey[500]))]));
                    }

                    return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final docId = doc.id;
                        final isSaved = _savedScholarshipIds.contains(docId);

                        // Format Deadline
                        String deadlineText = "N/A"; 
                        if (data['deadline'] != null) {
                          if (data['deadline'] is Timestamp) {
                            Timestamp t = data['deadline'] as Timestamp;
                            deadlineText = DateFormat('dd MMM yyyy').format(t.toDate());
                          } else {
                            deadlineText = data['deadline'].toString();
                          }
                        }

                        String webLink = (data['link'] ?? "").toString();

                        return _buildScholarshipCard(
                          name: data['title'] ?? "Unknown Scholarship Name",
                          provider: data['provider'] ?? "Unknown Provider",
                          amount: data['category'] ?? "N/A",
                          deadline: deadlineText,
                          spmReq: data['spm_result'] ?? "General",
                          isSaved: isSaved,
                          onSaveTap: () {
                            _handleSave(docId, data);
                          },
                          onApplyTap: (){
                            _confirmAndLaunchURL(webLink);
                          }
                        );
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

  // --- WIDGET HELPER ---
  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Padding(padding: const EdgeInsets.only(left: 10.0), child: Chip(label: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white)), backgroundColor: Colors.black87, deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white), onDeleted: onDeleted));
  }
  
  Widget _buildTabButton(String title, bool isActive) {
     return GestureDetector(
      onTap: () => setState(() => _showSavedOnly = (title == "Saved")),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildScholarshipCard({
    required String name, required String provider, required String amount, 
    required String deadline, required String spmReq,
    required bool isSaved, required VoidCallback onSaveTap, required VoidCallback onApplyTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)), child: Text(amount, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green[700]))),
                  ],
                ),
              ),
              GestureDetector(onTap: onSaveTap, child: Icon(isSaved ? Icons.favorite : Icons.favorite_border_rounded, color: isSaved ? Colors.red : Colors.grey[400], size: 24))
            ],
          ),
          const SizedBox(height: 10),
          Text("Provided by $provider", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Deadline: $deadline", style: TextStyle(color: Colors.red[400], fontSize: 12, fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: onApplyTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), 
                  decoration: BoxDecoration(
                    color: primaryColor, 
                    borderRadius: BorderRadius.circular(20)), 
                child: const Text("View Scholarships", 
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 12, 
                  fontWeight: FontWeight.bold))),
              )
            ],
          )
        ],
      ),
    );
  }

  // --- LAUNCH URL ---
  Future<void> _confirmAndLaunchURL(String url) async {
    String finalUrl = url.trim();

    if (finalUrl.isEmpty || finalUrl == "N/A") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No website link provided.")),
      );
      return;
    }

    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      finalUrl = 'https://$finalUrl';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Leaving App", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("You will be leaving this application to open this link."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final Uri uri = Uri.parse(finalUrl);
                if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                   throw 'Could not launch $finalUrl';
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error opening link: $finalUrl")),
                  );
                }
              }
            },
            child: const Text("Continue", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}