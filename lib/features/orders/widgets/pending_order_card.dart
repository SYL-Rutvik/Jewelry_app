import 'package:flutter/material.dart';

class PendingOrderCard extends StatelessWidget {
  // --- FIX: Add constructor to accept dynamic order data ---
  final Map<String, dynamic> order;
  const PendingOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Helper function to create styled rows for order details and totals
    Widget buildInfoRow({
      required String title,
      required String value,
      bool isTotal = false,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isTotal ? Colors.black : Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Helper function for the item rows
    Widget buildItemRow(Map<String, dynamic> item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            Text(
              '${item['name']}  ',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              'x${item['quantity']}',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const Spacer(),
            Text(
              '₹${(item['price'] as double).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 0, // Set to 0 if it's inside a Scaffold body
      color: Theme.of(context).canvasColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- FIX: Data is now dynamic ---
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEA5B43),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your order is on the way',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Click here to track your order',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.local_shipping_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            buildInfoRow(title: 'Order number', value: order['id']),
            buildInfoRow(
              title: 'Tracking Number',
              value: order['trackingNumber'],
            ),
            buildInfoRow(title: 'Delivery address', value: order['address']),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),

            // Item list - build from the 'items' list in the order data
            for (var item in (order['items'] as List)) buildItemRow(item),

            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            buildInfoRow(
              title: 'Sub Total',
              value: '₹${(order['subTotal'] as double).toStringAsFixed(2)}',
            ),
            buildInfoRow(
              title: 'Shipping',
              value: '₹${(order['shipping'] as double).toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            buildInfoRow(
              title: 'Total',
              value: '₹${(order['total'] as double).toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
}
