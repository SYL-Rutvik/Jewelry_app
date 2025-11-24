import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../auth/login_screen.dart';
import 'order_confirm_screen.dart'; // Final receipt screen

class DeliveryDetailsScreen extends StatefulWidget {
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems; // ✅ 1. ACCEPTS LIST OF CART ITEMS

  const DeliveryDetailsScreen({
    Key? key,
    required this.totalAmount,
    required this.cartItems, // REQUIRED
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

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  // ✅ 2. RENAME AND REWRITE FUNCTION TO PLACE ORDER
  void _placeOrder() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !mounted) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final String fullAddress =
        '${_addressController.text.trim()}, ${_cityController.text.trim()} - ${_pincodeController.text.trim()}';

    try {
      // 3. Prepare Order Data
      final Map<String, dynamic> deliveryAddress = {
        'fullName': _nameController.text.trim(),
        'addressLine1': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'pincode': _pincodeController.text.trim(),
      };

      final Map<String, dynamic> finalOrderData = {
        'userId': uid,
        'orderStatus': 'Confirmed (COD)',
        'totalAmount': widget.totalAmount,
        'shippingFee': 0.00,
        'deliveryAddress': deliveryAddress,
        'items': widget.cartItems,
        'timestamp': FieldValue.serverTimestamp(),
        'trackingNumber':
            'SPK-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', // Unique temp ID
      };

      // 4. Write Order to Firestore
      final orderRef = await FirebaseFirestore.instance
          .collection('orders')
          .add(finalOrderData);

      // 5. Clear User's Cart (using a Batch Write for efficiency)
      final batch = FirebaseFirestore.instance.batch();
      final cartCollectionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cart');

      // Delete all items in the cart
      for (var item in widget.cartItems) {
        batch.delete(cartCollectionRef.doc(item['id']));
      }
      await batch.commit();

      // 6. Navigate to Confirmation Screen (Receipt)
      setState(() => _isLoading = false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmScreen(
            // Pass the data needed for the receipt page
            order: {
              'id': orderRef.id,
              'total': widget.totalAmount,
              'items': widget.cartItems,
              'address': fullAddress, // Pass combined address
              'subTotal': widget.totalAmount,
              'shipping': 0.00,
              'trackingNumber': finalOrderData['trackingNumber'],
            },
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order failed to process: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper for consistent input decoration
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

  Widget _buildAddressForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('Full Name', Icons.person),
            validator: (v) => v!.isEmpty ? 'Enter your name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: _inputDecoration('Address Line 1', Icons.location_on),
            validator: (v) => v!.isEmpty ? 'Enter your address' : null,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  decoration: _inputDecoration('City', Icons.business),
                  validator: (v) => v!.isEmpty ? 'Enter city' : null,
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
                  validator: (v) => v!.isEmpty ? 'Enter pincode' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      });
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAddressForm(),
            const SizedBox(height: 30),

            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${widget.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF77F38),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _placeOrder, // Calls the order placement function
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF77F38),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Confirm Order (₹${widget.totalAmount.toStringAsFixed(2)})',
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
    );
  }
}
