// lib/screens/order_details_screen.dart
import 'package:flutter/material.dart';
import '../core/home_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  // Constructor receives the final order receipt map
  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ 1. SAFELY EXTRACT ALL VALUES, PROVIDING DEFAULTS
    final String orderId = order['id']?.toString() ?? 'N/A';
    final String trackingNumber = order['trackingNumber']?.toString() ?? 'N/A';
    final String address = order['address']?.toString() ?? 'N/A';

    // Ensure items is a list, even if null
    final List<dynamic> items = order['items'] as List<dynamic>? ?? [];

    // Safely extract totals as double
    final double subTotal = (order['subTotal'] as num?)?.toDouble() ?? 0.0;
    final double shipping = (order['shipping'] as num?)?.toDouble() ?? 0.0;
    final double total = (order['total'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFE0EAE9),
      appBar: _buildAppBar(context, orderId),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderStatusCard(context),
            const SizedBox(height: 20),
            _buildOrderInfoCard(orderId, trackingNumber, address),
            const SizedBox(height: 20),
            // Pass the item list for dynamic display
            _buildProductSummaryCard(items),
            const SizedBox(height: 20),
            // Pass the calculated totals
            _buildPriceSummaryCard(subTotal, shipping, total),
            const SizedBox(height: 40),
            _buildHomeButton(context),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, String orderId) {
    return AppBar(
      backgroundColor: const Color(0xFFE0EAE9),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black54),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Order #$orderId', // Displays the dynamic ID
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
        children: const [
          Expanded(
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
          Icon(Icons.delivery_dining, color: Colors.white, size: 60),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(
    String orderId,
    String trackingNumber,
    String address,
  ) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Order number', orderId),
          const SizedBox(height: 10),
          _buildInfoRow('Tracking Number', trackingNumber),
          const SizedBox(height: 10),
          _buildInfoRow('Delivery address', address),
        ],
      ),
    );
  }

  // Helper method: accepts dynamic values and converts them to string safely
  Widget _buildInfoRow(String title, dynamic value) {
    String displayValue = value?.toString() ?? 'N/A';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            displayValue,
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

  // ✅ 2. FIX: PROCESS ITEMS LIST AND BUILD CARDS
  Widget _buildProductSummaryCard(List<dynamic> items) {
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
        children: items.map((item) {
          // Safely extract item details
          final String name = item['name']?.toString() ?? 'Unknown Item';
          final int quantity = (item['quantity'] as int?) ?? 0;
          final double price = (item['price'] as num?)?.toDouble() ?? 0.0;

          return _buildProductItem(name, quantity, price);
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
              '₹${(price * quantity).toStringAsFixed(2)}', // Total price for item
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF3A3A3A),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummaryCard(
    double subTotal,
    double shipping,
    double total,
  ) {
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
            subTotal.toStringAsFixed(2),
            titleStyle,
            valueStyle,
          ),
          const SizedBox(height: 10),
          _buildPriceRow(
            'Shipping',
            shipping.toStringAsFixed(2),
            titleStyle,
            valueStyle,
          ),
          const Divider(height: 30),
          _buildPriceRow(
            'Total',
            total.toStringAsFixed(2),
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
