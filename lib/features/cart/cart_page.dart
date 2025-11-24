import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
import '../checkout/delivery_details_screen.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // UPDATE QUANTITY OR REMOVE ITEM LOGIC WITH STOCK CHECK
  Future<void> _updateQuantity(
    String productId,
    int currentQuantity,
    int change,
    int stockQuantity,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final newQuantity = currentQuantity + change;
    final cartRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(productId);

    // Safety checks
    if (newQuantity > stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cannot add more; stock limit reached."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (newQuantity <= 0) {
        await cartRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Item removed from cart."),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        await cartRef.update({'quantity': newQuantity});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update cart: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // LOGIC TO REMOVE ITEM
  Future<void> _removeItem(String productId, String name) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(productId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$name removed from cart."),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to remove item: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmAndRemoveItem(
    BuildContext context,
    String productId,
    String name,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Remove from Cart'),
          content: Text(
            'Are you sure you want to remove "$name" from your cart?',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              onPressed: () {
                _removeItem(productId, name);
                Navigator.of(ctx).pop();
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6FF6F),
      // ✅ FIX: _buildAppBar is now defined below
      appBar: _buildAppBar(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          // --- CALCULATE LIVE TOTALS AND COLLECT ITEMS ---
          List<Map<String, dynamic>> cartItems = [];
          double subTotal = 0;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final price = (data['price'] as num? ?? 0.0).toDouble();
            final quantity = (data['quantity'] as int? ?? 0);

            subTotal += price * quantity;

            cartItems.add({
              'id': doc.id,
              'name': data['name'],
              'price': price,
              'quantity': quantity,
              'imageUrl': data['imageUrl'],
              'stockQuantity': data['stockQuantity'],
            });
          }

          const double shippingFee = 0.00;
          final double finalTotal = subTotal + shippingFee;

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          return Column(
            children: [
              // --- Cart Items List ---
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final item = doc.data() as Map<String, dynamic>;
                    // ✅ FIX: _buildCartItemCard is now defined below
                    return _buildCartItemCard(item, doc.id);
                  },
                ),
              ),

              // --- Price Summary and Checkout Button ---
              _buildPriceSummary(context, subTotal, finalTotal, cartItems),
            ],
          );
        },
      ),
    );
  }

  // ✅ FIX: ADDED MISSING HELPER METHOD
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'My Cart',
        style: TextStyle(color: Color(0xFF3A3A3A), fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black54),
      centerTitle: true,
    );
  }

  // ✅ FIX: ADDED MISSING HELPER METHOD
  Widget _buildCartItemCard(Map<String, dynamic> item, String docId) {
    final String name = item['name'] ?? 'N/A';
    final double price = (item['price'] as num? ?? 0.0).toDouble();
    final int quantity = (item['quantity'] as int? ?? 0);
    final String imageUrl = item['imageUrl'] ?? '';
    final int stockQuantity = (item['stockQuantity'] as int? ?? 0);

    final bool canIncrement = quantity < stockQuantity;
    final bool canDecrement = quantity > 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () =>
                            _confirmAndRemoveItem(context, docId, name),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${price.toStringAsFixed(2)} / pc',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: ₹${(price * quantity).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF77F38),
                    ),
                  ),
                  if (quantity == stockQuantity && stockQuantity > 0)
                    const Text(
                      'Max Stock Reached',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

            // Quantity Control
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    icon: const Icon(Icons.remove, size: 20),
                    onPressed: canDecrement
                        ? () => _updateQuantity(
                            docId,
                            quantity,
                            -1,
                            stockQuantity,
                          )
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '$quantity',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: canIncrement
                        ? () =>
                              _updateQuantity(docId, quantity, 1, stockQuantity)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FIX: ADDED MISSING HELPER METHOD
  Widget _buildPriceSummary(
    BuildContext context,
    double subTotal,
    double finalTotal,
    List<Map<String, dynamic>> cartItems,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow('Subtotal', subTotal),
          const SizedBox(height: 8),
          _buildSummaryRow('Shipping', 0.00),
          const Divider(height: 20),
          _buildSummaryRow('Total', finalTotal, isTotal: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: finalTotal > 0
                  ? () {
                      // Navigate to DeliveryDetailsScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeliveryDetailsScreen(
                            totalAmount: finalTotal,
                            cartItems: cartItems,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF77F38),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Checkout',
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
    );
  }

  // ✅ FIX: ADDED MISSING HELPER METHOD
  Widget _buildSummaryRow(String title, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? const Color(0xFFF77F38) : Colors.black,
          ),
        ),
      ],
    );
  }
}
