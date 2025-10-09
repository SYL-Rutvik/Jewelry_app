// lib/screens/cart_page.dart
import 'package:flutter/material.dart';
import 'delivery_details_screen.dart'; // Import the first screen of the checkout flow

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Mock data for cart items
  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': '1',
      'name': 'Aurora Gemstone Ring For Women..',
      'price': 150.00,
      'quantity': 1,
      'imageUrl': 'https://i.imgur.com/8Q0N6W0.png',
    },
    {
      'id': '2',
      'name': 'Eluria Diamond Ring For Women...',
      'price': 125.00,
      'quantity': 1,
      'imageUrl': 'https://i.imgur.com/fk6jB5G.png',
    },
    {
      'id': '3',
      'name': 'Sapphire Locket For Women',
      'price': 70.00,
      'quantity': 1,
      'imageUrl': 'https://i.imgur.com/RW8Kn5x.png',
    },
  ];

  double get _subtotal {
    return _cartItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
  }

  void _incrementQuantity(String id) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item['id'] == id);
      if (index != -1) {
        _cartItems[index]['quantity']++;
      }
    });
  }

  void _decrementQuantity(String id) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item['id'] == id);
      if (index != -1 && _cartItems[index]['quantity'] > 1) {
        _cartItems[index]['quantity']--;
      }
    });
  }

  void _deleteItem(String id) {
    setState(() {
      _cartItems.removeWhere((item) => item['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFE0EAE9,
      ), // Background color from the image
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: _cartItems.isEmpty
                ? const Center(
                    child: Text(
                      'Your cart is empty.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return _buildCartItemCard(item);
                    },
                  ),
          ),
          _buildBottomSummaryAndCheckout(),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFE0EAE9),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black54),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Cart',
            style: TextStyle(
              color: Color(0xFF3A3A3A),
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          SizedBox(width: 8),
          Icon(
            Icons.shopping_cart_outlined,
            color: Color(0xFFF77F38),
            size: 28,
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildCartItemCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item['imageUrl'],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A3A3A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${item['price'].toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3A3A3A),
                      ),
                    ),
                    _buildQuantityControls(item['id'], item['quantity']),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () => _deleteItem(item['id']),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(String id, int quantity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _decrementQuantity(id),
          child: const Icon(
            Icons.remove_circle_outline,
            color: Colors.grey,
            size: 22,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 30,
          alignment: Alignment.center,
          child: Text(
            quantity.toString(),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _incrementQuantity(id),
          child: const Icon(
            Icons.add_circle_outline,
            color: Colors.grey,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSummaryAndCheckout() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal :',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A3A3A),
                ),
              ),
              Text(
                '₹${_subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A3A3A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cartItems.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeliveryDetailsScreen(),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF77F38),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                shadowColor: const Color(0xFFF77F38).withOpacity(0.4),
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
}
