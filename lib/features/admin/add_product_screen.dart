import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Initialize Cloudinary (Use your existing configuration)
final cloudinary = CloudinaryPublic(
  'dtdcca3jl', // ⬅️ PUT YOUR CLOUD NAME HERE
  'flutter_uploads', // ⬅️ PUT YOUR UNSIGNED UPLOAD PRESET NAME HERE
  cache: false,
);

class AddProductScreen extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? initialData;

  const AddProductScreen({Key? key, this.productId, this.initialData})
    : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _karatController = TextEditingController();
  final _weightController = TextEditingController();
  final _sizeController = TextEditingController();
  final _stockController = TextEditingController(); // Stock Controller

  String? _selectedCategory;
  XFile? _imageXFile;
  String? _downloadUrl;
  String? _imageUploadStatus;
  bool _isImageUploading = false;
  bool _imageUploadSuccess = false;
  bool _isSaving = false;
  String? _originalImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null && widget.initialData != null) {
      _loadInitialData(widget.initialData!);
    }
  }

  void _loadInitialData(Map<String, dynamic> data) {
    _nameController.text = data['name'] ?? '';
    _priceController.text = data['price']?.toString() ?? '';
    _descriptionController.text = data['description'] ?? '';
    _karatController.text = data['karat'] ?? '';
    _weightController.text = data['weight'] ?? '';
    _sizeController.text = data['size'] ?? '';
    _stockController.text = data['stockQuantity']?.toString() ?? '0';

    _selectedCategory = data['category'];
    _originalImageUrl = data['imageUrl'];
    _downloadUrl = data['imageUrl'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _karatController.dispose();
    _weightController.dispose();
    _sizeController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;

    setState(() {
      _imageXFile = pickedFile;
      _imageUploadStatus = 'Uploading...';
      _imageUploadSuccess = false;
      _downloadUrl = null;
    });

    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(pickedFile.path),
      );

      setState(() {
        _downloadUrl = response.secureUrl;
        _imageUploadStatus = 'Image uploaded successfully!';
        _imageUploadSuccess = true;
      });
    } catch (e) {
      setState(() {
        _imageUploadStatus = 'Upload failed. Please try again.';
        _imageUploadSuccess = false;
        _downloadUrl = null;
      });
    }
  }

  Future<void> _uploadAndSaveProduct() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    if (_downloadUrl == null && _imageXFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for image upload or upload a new image.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Prepare the data map
      Map<String, dynamic> productData = {
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'karat': _karatController.text.trim(),
        'weight': _weightController.text.trim(),
        'size': _sizeController.text.trim(),
        'stockQuantity': int.tryParse(_stockController.text.trim()) ?? 0,
        'imageUrl': _downloadUrl, // Use the new (or old) Cloudinary URL
      };

      if (widget.productId == null) {
        // ADD NEW PRODUCT MODE
        await FirebaseFirestore.instance.collection('products').add({
          ...productData,
          'createdAt': Timestamp.now(),
        });
      } else {
        // EDIT EXISTING PRODUCT MODE
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .update(productData);
      }

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Product ${widget.productId == null ? 'added' : 'updated'} successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditMode = widget.productId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF77F38),
        elevation: 0,
        title: Text(
          isEditMode ? 'Edit Product' : 'Add New Product',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditMode ? 'Edit Product Details' : 'Add New Product',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A3A3A),
                ),
              ),
              const SizedBox(height: 30),

              // --- IMAGE UPLOAD AREA ---
              GestureDetector(
                onTap: _pickAndUploadImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildImageWidget(),
                  ),
                ),
              ),
              if (_imageUploadStatus != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _imageUploadStatus!,
                    style: TextStyle(
                      color: _imageUploadSuccess ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // --- INPUT FIELDS ---
              _buildTextFormField(
                controller: _nameController,
                label: 'Product Name',
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _priceController,
                label: 'Price',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _karatController,
                      label: 'Karat (e.g. 24k)',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _weightController,
                      label: 'Weight (e.g. 10g)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _sizeController,
                label: 'Size (e.g. 4 cm)',
              ),
              const SizedBox(height: 16),

              // Stock Field
              _buildTextFormField(
                controller: _stockController,
                label: 'Stock Quantity',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // --- CATEGORY DROPDOWN ---
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('categories')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: Text('Loading categories...'));
                  var categories = snapshot.data!.docs
                      .map(
                        (doc) => DropdownMenuItem<String>(
                          value: doc['name'],
                          child: Text(doc['name']),
                        ),
                      )
                      .toList();
                  return DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: const Text('Select Category'),
                    decoration: _inputDecoration(),
                    items: categories,
                    onChanged: (val) => setState(() => _selectedCategory = val),
                    validator: (val) => val == null ? 'Required' : null,
                  );
                },
              ),
              const SizedBox(height: 30),

              // --- SAVE BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _uploadAndSaveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF77F38),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditMode ? 'Update Product' : 'Save Product',
                          style: const TextStyle(
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

  // Helper function to handle image display logic
  Widget _buildImageWidget() {
    if (_isImageUploading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_imageXFile != null) {
      return kIsWeb
          ? Image.network(_imageXFile!.path, fit: BoxFit.cover)
          : Image.file(File(_imageXFile!.path), fit: BoxFit.cover);
    }

    if (_originalImageUrl != null && _originalImageUrl!.isNotEmpty) {
      return Image.network(_originalImageUrl!, fit: BoxFit.cover);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, color: Colors.grey.shade500, size: 40),
        const SizedBox(height: 8),
        Text(
          'Upload Image here',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Helper function for input fields
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: _inputDecoration().copyWith(labelText: label),
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
    );
  }

  // Helper function for consistent input decoration
  InputDecoration _inputDecoration() {
    return InputDecoration(
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
