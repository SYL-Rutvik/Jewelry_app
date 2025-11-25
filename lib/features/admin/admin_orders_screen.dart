import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../orders/order_details_screen.dart'; // Re-use the receipt screen

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({Key? key}) : super(key: key);

  // ✅ 1. UPDATE STATUS LOGIC (Edit)
  void _showEditStatusDialog(
    BuildContext context,
    String docId,
    String currentStatus,
  ) {
    String? selectedStatus = currentStatus;
    final List<String> statuses = [
      'Pending',
      'Confirmed (COD)',
      'Shipped',
      'Delivered',
      'Cancelled',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Update Order Status'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButtonFormField<String>(
                value: statuses.contains(selectedStatus)
                    ? selectedStatus
                    : statuses.first,
                items: statuses.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (val) => setState(() => selectedStatus = val),
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStatus != null) {
                  await FirebaseFirestore.instance
                      .collection('orders')
                      .doc(docId)
                      .update({'orderStatus': selectedStatus});

                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Status updated to $selectedStatus"),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF77F38),
              ),
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ 2. DELETE ORDER LOGIC
  void _confirmDeleteOrder(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Delete Order'),
          content: const Text(
            'Are you sure you want to delete this order permanently?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('orders')
                    .doc(docId)
                    .delete();
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Order deleted successfully"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF77F38),
        elevation: 0,
        title: const Text(
          'ADMIN - Orders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // ✅ 3. STREAM BUILDER FOR ORDERS
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true) // Show newest first
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final order = doc.data() as Map<String, dynamic>;

              // Safely extract data
              // Note: Depending on how you saved it, it might be 'id', 'orderId', or doc.id
              // We passed 'id': orderRef.id in delivery_details, but also saved 'trackingNumber'
              final String trackingNum =
                  order['trackingNumber']?.toString() ?? doc.id.substring(0, 8);
              final String customerName =
                  order['deliveryAddress']?['fullName']?.toString() ??
                  'Unknown';
              final double total =
                  (order['totalAmount'] as num?)?.toDouble() ?? 0.0;
              final String status =
                  order['orderStatus']?.toString() ?? 'Pending';
              final Timestamp? timestamp = order['timestamp'] as Timestamp?;
              final String date = timestamp != null
                  ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}"
                  : "N/A";

              // Prepare map for OrderDetailsScreen (needs to match what that screen expects)
              final Map<String, dynamic> orderDataForDetail = {
                ...order,
                'id': doc.id, // Ensure ID is passed
                'total': total, // Map 'totalAmount' to 'total' if needed
                'subTotal': total,
                'shipping': order['shippingFee'] ?? 0.0,
                'address':
                    '${order['deliveryAddress']?['addressLine1'] ?? ''}, ${order['deliveryAddress']?['city'] ?? ''}',
              };

              return _buildOrderCard(
                context,
                doc.id,
                trackingNum,
                customerName,
                total,
                status,
                date,
                orderDataForDetail,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    String docId,
    String trackingNum,
    String customer,
    double total,
    String status,
    String date,
    Map<String, dynamic> fullOrderData,
  ) {
    // Color code the status
    Color statusColor = Colors.blue;
    if (status == 'Delivered') statusColor = Colors.green;
    if (status == 'Cancelled') statusColor = Colors.red;
    if (status == 'Confirmed (COD)') statusColor = Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Top Row: Icon + Info
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF77F38).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: Color(0xFFF77F38),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: $trackingNum',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Date: $date',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF3A3A3A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 20),
            // Bottom Row: Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  text: 'View',
                  color: Colors.blue,
                  icon: Icons.visibility,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderDetailsScreen(order: fullOrderData),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  text: 'Edit',
                  color: Colors.orange,
                  icon: Icons.edit,
                  onPressed: () =>
                      _showEditStatusDialog(context, docId, status),
                ),
                _buildActionButton(
                  text: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onPressed: () => _confirmDeleteOrder(context, docId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(icon, size: 14, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
