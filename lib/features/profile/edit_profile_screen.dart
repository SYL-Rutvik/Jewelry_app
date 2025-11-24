import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// ✅ Initialize Cloudinary
// REPLACE WITH YOUR ACTUAL CREDENTIALS
final cloudinary = CloudinaryPublic(
  'dtdcca3jl', // Your Cloud Name
  'flutter_uploads', // Your Unsigned Upload Preset
  cache: false,
);

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _ageController = TextEditingController();

  String? _uid;
  String? _email;
  String? _profileImageUrl; // Holds the URL of the user's photo

  bool _isLoading = false; // For the "Update" button
  bool _isImageUploading = false; // For the profile pic loading
  XFile? _imageXFile; // Holds the picked file

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ✅ 1. LOAD CURRENT USER DATA FROM FIRESTORE
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _uid = user.uid;
      _email = user.email;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _nameController.text = data['fullName'] ?? '';
        _cityController.text = data['city'] ?? '';
        _ageController.text = data['age']?.toString() ?? '';

        if (mounted) {
          setState(() {
            _profileImageUrl = data['profileImageUrl'];
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // ✅ 2. PICK AND UPLOAD A NEW PROFILE IMAGE TO CLOUDINARY
  Future<void> _pickAndUploadImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    setState(() {
      _imageXFile = pickedFile;
      _isImageUploading = true;
    });

    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(pickedFile.path),
      );

      setState(() {
        _profileImageUrl = response.secureUrl; // Save the new URL
        _isImageUploading = false;
      });
    } catch (e) {
      setState(() {
        _isImageUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ 3. UPDATE THE PROFILE IN FIRESTORE
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Prepare the data map
      Map<String, dynamic> dataToUpdate = {
        'fullName': _nameController.text.trim(),
        'city': _cityController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
      };

      // Only update the image URL if a new one exists
      if (_profileImageUrl != null) {
        dataToUpdate['profileImageUrl'] = _profileImageUrl;
      }

      // Update the user's document in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .update(dataToUpdate);

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(); // Go back to home
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFFF77F38),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // --- PROFILE IMAGE ---
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey.shade300,
                      // Logic: Show Local File -> OR Show Network URL -> OR Show Icon
                      backgroundImage: _imageXFile != null
                          ? (kIsWeb
                                    ? NetworkImage(_imageXFile!.path)
                                    : FileImage(File(_imageXFile!.path)))
                                as ImageProvider
                          : (_profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : null),
                      child:
                          (_profileImageUrl == null &&
                              _imageXFile == null &&
                              !_isImageUploading)
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    if (_isImageUploading) const CircularProgressIndicator(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.edit,
                            color: Color(0xFFF77F38),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- EMAIL (Read-only) ---
              if (_email != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _email!,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // --- FULL NAME ---
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Full Name', Icons.person),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- CITY ---
              TextFormField(
                controller: _cityController,
                decoration: _inputDecoration('City', Icons.location_city),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- AGE ---
              TextFormField(
                controller: _ageController,
                decoration: _inputDecoration('Age', Icons.cake),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // --- UPDATE BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF77F38),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Update Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
