import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_confirm_screen.dart';
import '../auth/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for FieldValue import if you use it

class PaymentScreen extends StatefulWidget {
  // ✅ 1. CORRECT CONSTRUCTOR DEFINITION
  final double totalAmount;
  final Map<String, String> deliveryAddress;

  const PaymentScreen({
    Key? key,
    required this.totalAmount,
    required this.deliveryAddress,
  }) : super(key: key); // Correctly initialized super

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'COD';
  bool _isLoading = false;

  void _confirmOrder() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }

    if (_selectedPaymentMethod != 'COD') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Only Cash on Delivery is available for this demo."),
        ),
      );
      return;
    }

    // 1. Prepare Order Data (Simulation for COD)
    Map<String, dynamic> finalOrderData = {
      'orderId': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      'userId': uid,
      'total': widget.totalAmount,
      'subTotal': widget.totalAmount,
      'shipping': 0.00,
      'items': [], // Placeholder items
      'deliveryAddress': widget.deliveryAddress,
      'paymentMethod': _selectedPaymentMethod,
      'status': 'Confirmed',
      'trackingNumber': 'TRK-${DateTime.now().millisecondsSinceEpoch}',
    };

    setState(() => _isLoading = true);

    // 2. Navigate to Order Confirmation (Receipt Screen)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        // Pass the simplified data structure needed for OrderDetailsScreen
        builder: (context) => OrderConfirmScreen(
          order: {
            'id': finalOrderData['orderId'],
            'total': finalOrderData['total'],
            'items': finalOrderData['items'],
            // Combine address fields for display
            'address':
                '${widget.deliveryAddress['addressLine1']}, ${widget.deliveryAddress['city']} - ${widget.deliveryAddress['pincode']}',
            'subTotal': finalOrderData['subTotal'],
            'shipping': finalOrderData['shipping'],
            'trackingNumber': finalOrderData['trackingNumber'],
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Safety check: handle user not logged in
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Extract passed data from widget
    final total = widget.totalAmount;
    final address = widget.deliveryAddress;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Color(0xFF3A3A3A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            _buildSummaryCard(total),
            const SizedBox(height: 20),

            // Delivery Address Summary
            const Text(
              'Shipping Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              address['fullName'] ?? 'N/A',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Text(
              '${address['addressLine1']}, ${address['city']} - ${address['pincode']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Payment Method Section
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPaymentOptions(),

            const Spacer(),

            // Confirm Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmOrder,
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
                        'Pay ₹${total.toStringAsFixed(2)}',
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

  Widget _buildSummaryCard(double total) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Final Total:',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              '₹${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF77F38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Text('Cash on Delivery (COD)'),
            value: 'COD',
            groupValue: _selectedPaymentMethod,
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _selectedPaymentMethod = value);
              }
            },
            activeColor: const Color(0xFFF77F38),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          RadioListTile<String>(
            title: const Text('UPI Apps (GPay, PhonePe, etc)'),
            secondary: const Icon(Icons.apps_outage_rounded),
            value: 'UPI',
            groupValue: _selectedPaymentMethod,
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _selectedPaymentMethod = value);
              }
            },
            activeColor: const Color(0xFFF77F38),
          ),
        ],
      ),
    );
  }
}
