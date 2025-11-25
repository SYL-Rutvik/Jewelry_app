import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart'; // ✅ Import Razorpay
import 'order_confirm_screen.dart';
import '../auth/login_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final Map<String, String> deliveryAddress;
  final List<Map<String, dynamic>> cartItems; // ✅ Accepts Cart Items

  const PaymentScreen({
    Key? key,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.cartItems,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'COD';
  bool _isLoading = false;
  late Razorpay _razorpay; // Razorpay Instance

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    // Attach Event Listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Clear listeners
    super.dispose();
  }

  // ✅ 1. HANDLE SUCCESSFUL PAYMENT
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment Successful! Now save the order to Firestore.
    _processOrder(
      paymentMethod: 'Online (Razorpay)',
      paymentId: response.paymentId,
      status: 'Confirmed',
    );
  }

  // ✅ 2. HANDLE PAYMENT FAILURE
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
    setState(() => _isLoading = false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  // ✅ 3. TRIGGER RAZORPAY CHECKOUT
  void _openCheckout() {
    var options = {
      'key': 'rzp_test_Rjflu9txZXx7mR', // ⚠️ REPLACE WITH YOUR KEY ID
      'amount': (widget.totalAmount * 100).toInt(), // Amount in paise
      'name': 'Sparkles Jewellery',
      'description': 'Order Payment',
      'prefill': {
        'contact': '9023650308', // You can get this from user profile
        'email': FirebaseAuth.instance.currentUser?.email ?? 'test@test.com',
      },
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // ✅ 4. MAIN FUNCTION TO SAVE ORDER TO FIREBASE
  void _processOrder({
    required String paymentMethod,
    String? paymentId,
    required String status,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      // Prepare Order Data
      Map<String, dynamic> finalOrderData = {
        'userId': uid,
        'totalAmount': widget.totalAmount,
        'subTotal': widget.totalAmount, // Add logic for shipping if needed
        'shippingFee': 0.00,
        'items': widget.cartItems,
        'deliveryAddress': widget.deliveryAddress,
        'paymentMethod': paymentMethod,
        'paymentId': paymentId ?? 'N/A',
        'orderStatus': status,
        'timestamp': FieldValue.serverTimestamp(),
        'trackingNumber': 'TRK-${DateTime.now().millisecondsSinceEpoch}',
      };

      // Write to Firestore
      final orderRef = await FirebaseFirestore.instance
          .collection('orders')
          .add(finalOrderData);

      // Clear Cart
      final batch = FirebaseFirestore.instance.batch();
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cart');

      for (var item in widget.cartItems) {
        batch.delete(cartRef.doc(item['id']));
      }
      await batch.commit();

      // Navigate to Receipt
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmScreen(
              order: {
                'id': orderRef.id,
                ...finalOrderData, // Spread the rest of the data
                // Ensure address is formatted for display if OrderConfirmScreen expects a string
                'address':
                    '${widget.deliveryAddress['addressLine1']}, ${widget.deliveryAddress['city']}',
              },
            ),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Order processing failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onPayButtonPressed() {
    if (_selectedPaymentMethod == 'COD') {
      _processOrder(paymentMethod: 'COD', status: 'Confirmed (COD)');
    } else {
      // Open Razorpay for Online Payment
      _openCheckout();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Summary
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
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
            ),
            const SizedBox(height: 20),

            // Address
            const Text(
              'Shipping To:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              '${address['fullName']}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${address['addressLine1']}, ${address['city']}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Methods
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Cash on Delivery (COD)'),
                    value: 'COD',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (val) =>
                        setState(() => _selectedPaymentMethod = val!),
                    activeColor: const Color(0xFFF77F38),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Online Payment (Razorpay)'),
                    secondary: const Icon(
                      Icons.credit_card,
                      color: Colors.blue,
                    ),
                    value: 'ONLINE',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (val) =>
                        setState(() => _selectedPaymentMethod = val!),
                    activeColor: const Color(0xFFF77F38),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Pay Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onPayButtonPressed,
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
                        _selectedPaymentMethod == 'COD'
                            ? 'Place Order'
                            : 'Pay Now',
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
