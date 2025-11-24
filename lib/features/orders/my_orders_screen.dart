import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ IMPORT AUTH
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ IMPORT FIRESTORE
import 'package:jewelery_app/features/orders/widgets/pending_order_card.dart';
import 'order_details_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _auth = FirebaseAuth.instance;

  // ❌ REMOVED: Static order lists are no longer needed.
  // final List<Map<String, dynamic>> _pendingOrders = [...];
  // final List<Map<String, dynamic>> _completedOrders = [...];
  // final List<Map<String, dynamic>> _cancelledOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check for logged-in user
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text("Please log in to view orders."));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildCustomTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ✅ PASS STATUS STRING TO NEW WIDGET
                _buildOrdersList('Confirmed (COD)'),
                _buildOrdersList('Delivered'),
                _buildOrdersList('Cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black54),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'My Orders',
        style: TextStyle(color: Color(0xFF3A3A3A), fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabChip('Pending', 0),
          _buildTabChip('Completed', 1),
          _buildTabChip('Cancelled', 2),
        ],
      ),
    );
  }

  Widget _buildTabChip(String text, int index) {
    bool isSelected = _tabController.index == index;
    // NOTE: We map "Pending" tab UI to "Confirmed (COD)" status in Firestore
    final statusText = text == 'Pending' ? 'Confirmed (COD)' : text;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF77F38) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF77F38)),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFF77F38),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ NEW: WIDGET ACCEPTS A STATUS STRING AND RETURNS A STREAMBUILDER
  Widget _buildOrdersList(String statusFilter) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text("Authentication error."));
    }

    return StreamBuilder<QuerySnapshot>(
      // ✅ COMPOUND QUERY: Filter by User ID AND Status
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .where('orderStatus', isEqualTo: statusFilter)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'You have no ${statusFilter.toLowerCase()} orders.',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final orderData = doc.data()! as Map<String, dynamic>;

            // Pass the document ID (doc.id) for details/tracking
            return _buildOrderCard(orderData, doc.id);
          },
        );
      },
    );
  }

  // ✅ UPDATED ORDER CARD WIDGET TO BE DYNAMIC
  Widget _buildOrderCard(Map<String, dynamic> order, String orderDocId) {
    // Safely extract nested data
    final String orderIdDisplay =
        order['id'] ?? orderDocId; // Use docId as fallback
    final Timestamp? timestamp = order['timestamp'] as Timestamp?;
    final String dateDisplay = timestamp != null
        ? '${timestamp.toDate().day}-${timestamp.toDate().month}-${timestamp.toDate().year}'
        : 'N/A';

    // Get the first item's details for the card preview
    final firstItem = (order['items'] as List<dynamic>?)?.first;
    final productName = firstItem?['name'] ?? 'Multiple Items';
    final price = (firstItem?['price'] as num?)?.toDouble() ?? 0.0;
    final quantity = (firstItem?['quantity'] as int?) ?? 1;
    final imageUrl = firstItem?['imageUrl'] ?? '';
    final statusColor = order['orderStatus'] == 'Delivered'
        ? Colors.green
        : Colors.blue;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    orderIdDisplay,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  dateDisplay,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantity: $quantity',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${(price * quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFF77F38),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order['orderStatus'],
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  // NOTE: This assumes OrderDetailsScreen can display any order status
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsScreen(order: order),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
