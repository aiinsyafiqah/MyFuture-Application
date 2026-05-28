import 'dart:io'; // Untuk handle File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myfuture_application/src/utils/theme/colors.dart'; // Import theme color awak

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers untuk Text Fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  // Variable untuk Gambar
  File? _pickedImageFile;
  String? _currentImageUrl;
  
  bool _isLoading = false;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 1. Load Data Lama User dari Firestore
  Future<void> _loadUserData() async {
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? currentUser!.email ?? '';
          _currentImageUrl = data['image_url']; // Pastikan field ni wujud nanti
        });
      }
    } catch (e) {
      print("Error loading data: $e");
    }

    setState(() => _isLoading = false);
  }

  // 2. Fungsi Pilih Gambar dari Galeri
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _pickedImageFile = File(image.path);
      });
    }
  }

  // 3. Fungsi Upload Gambar ke Firebase Storage
  Future<String?> _uploadImage() async {
    if (_pickedImageFile == null) return _currentImageUrl; // Kalau tak tukar gambar, guna yg lama

    try {
      final String fileName = 'profile_${currentUser!.uid}.jpg';
      final Reference ref = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child(fileName);

      await ref.putFile(_pickedImageFile!);
      return await ref.getDownloadURL(); // Dapat URL gambar baru
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // 4. Fungsi Simpan Semua Perubahan
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // A. Upload Gambar dulu (kalau ada baru)
      String? imageUrl = await _uploadImage();

      // B. Update Data dalam Firestore
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(), // Nota: Ini cuma update text di DB, bukan login email auth
        'image_url': imageUrl,
      });

      // C. Feedback & Keluar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully! ✅")),
        );
        Navigator.pop(context); // Balik ke page sebelum ni
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Edit Profile",
         style: TextStyle(color: primaryColor,
         fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- BAHAGIAN GAMBAR ---
                    Stack(
                      children: [
                        // Bulatan Gambar
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _pickedImageFile != null
                              ? FileImage(_pickedImageFile!) as ImageProvider
                              : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                  ? NetworkImage(_currentImageUrl!)
                                  : null),
                          child: (_pickedImageFile == null && (_currentImageUrl == null || _currentImageUrl!.isEmpty))
                              ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                              : null,
                        ),
                        
                        // Icon Kamera Kecil (Button)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primaryColor, // Warna tema awak
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),

                    // --- NAME FIELD ---
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Name cannot be empty';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // --- EMAIL FIELD ---
                    TextFormField(
                      controller: _emailController,
                      readOnly: true, // <--- 1. TAMBAH INI (Supaya tak boleh type)
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        
                        // 2. TAMBAH INI (Supaya nampak kelabu/disabled)
                        filled: true,
                        fillColor: Colors.grey[200], 
                        
                        // Tukar ayat helper text supaya user faham
                        helperText: "Email cannot be changed.",
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --- SAVE BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}