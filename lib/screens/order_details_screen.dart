// lib/screens/order_details_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Make sure this path is correct

class OrderDetailsScreen extends StatelessWidget {
  // --- FIX: Accept the full order map instead of just the ID ---
  final Map<String, dynamic> order;

  const OrderDetailsScreen({
    Key? key,
    required this.order,
    required String orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0EAE9),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderStatusCard(context),
            const SizedBox(height: 20),
            _buildOrderInfoCard(),
            const SizedBox(height: 20),
            _buildProductSummaryCard(),
            const SizedBox(height: 20),
            _buildPriceSummaryCard(),
            const SizedBox(height: 40),
            _buildHomeButton(context),
          ],
        ),
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
      // --- FIX: Use dynamic order ID ---
      title: Text(
        'Order #${order['id']}',
        style: const TextStyle(
          color: Color(0xFF3A3A3A),
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildOrderStatusCard(BuildContext context) {
    // This card can remain static or be updated with dynamic data if needed
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF77F38),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF77F38).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Placed Successfully',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Click here to track your order',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(Icons.delivery_dining, color: Colors.white, size: 60),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // --- FIX: Use dynamic order data ---
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Order number', order['id']),
          const SizedBox(height: 10),
          _buildInfoRow('Tracking Number', order['trackingNumber']),
          const SizedBox(height: 10),
          _buildInfoRow('Delivery address', order['address']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF3A3A3A),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // --- FIX: Build product items from the 'items' list in the order data ---
      child: Column(
        children: (order['items'] as List<dynamic>).map((item) {
          return _buildProductItem(
            item['name'],
            item['quantity'],
            item['price'],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductItem(String name, int quantity, double price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xFF3A3A3A),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            'x$quantity',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 80,
            child: Text(
              '₹${price.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF3A3A3A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummaryCard() {
    // --- FIX: Use dynamic order data ---
    const Color textColor = Color(0xFF3A3A3A);
    const TextStyle titleStyle = TextStyle(fontSize: 16, color: Colors.grey);
    const TextStyle valueStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: textColor,
    );
    const TextStyle totalValueStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: textColor,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow(
            'Sub Total',
            order['subTotal'].toStringAsFixed(2),
            titleStyle,
            valueStyle,
          ),
          const SizedBox(height: 10),
          _buildPriceRow(
            'Shipping',
            order['shipping'].toStringAsFixed(2),
            titleStyle,
            valueStyle,
          ),
          const Divider(height: 30),
          _buildPriceRow(
            'Total',
            order['total'].toStringAsFixed(2),
            const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            totalValueStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String title,
    String value,
    TextStyle titleStyle,
    TextStyle valueStyle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: titleStyle),
        Text('₹$value', style: valueStyle),
      ],
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF77F38),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
