import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';
import 'payment_screen.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems; // Required to pass to payment

  const DeliveryDetailsScreen({
    Key? key,
    required this.totalAmount,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final Map<String, String> deliveryAddress = {
      'fullName': _nameController.text.trim(),
      'addressLine1': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'pincode': _pincodeController.text.trim(),
    };

    // ✅ NAVIGATE TO PAYMENT SCREEN AND PASS CART ITEMS
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          totalAmount: widget.totalAmount,
          deliveryAddress: deliveryAddress,
          cartItems: widget.cartItems, // ✅ PASS ITEMS HERE
        ),
      ),
    );
  }

  // Helper for input decoration
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

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text(
          'Delivery Details',
          style: TextStyle(
            color: Color(0xFF3A3A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delivery Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Address Form Fields
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Full Name', Icons.person),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: _inputDecoration(
                  'Address Line 1',
                  Icons.location_on,
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: _inputDecoration('City', Icons.business),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _pincodeController,
                      decoration: _inputDecoration(
                        'Pincode',
                        Icons.local_post_office,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Proceed Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _proceedToPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF77F38),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Proceed to Payment (₹${widget.totalAmount.toStringAsFixed(2)})',
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
}
