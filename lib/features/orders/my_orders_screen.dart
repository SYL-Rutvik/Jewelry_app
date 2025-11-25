import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_details_screen.dart'; // Import the receipt screen

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _auth = FirebaseAuth.instance;

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
                // Tab 1: Active/Pending Orders
                // We include all 'active' statuses here
                _buildOrdersList([
                  'Pending',
                  'Confirmed',
                  'Confirmed (COD)',
                  'Shipped',
                ]),

                // Tab 2: Completed Orders
                _buildOrdersList(['Delivered']),

                // Tab 3: Cancelled Orders
                _buildOrdersList(['Cancelled']),
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

  // ✅ UPDATED: Accepts a LIST of statuses to filter by
  Widget _buildOrdersList(List<String> statusFilters) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Center(child: Text("Auth Error"));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: uid)
          // ✅ KEY CHANGE: Use 'whereIn' to match ANY of the statuses in the list
          .where('orderStatus', whereIn: statusFilters)
          // Note: You might need to create an Index for this query!
          // Check your Debug Console if it doesn't load.
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 60,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 10),
                const Text(
                  'No orders found.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        // Sort locally if backend sorting conflicts with 'whereIn'
        final docs = snapshot.data!.docs;
        // Optional: sort by timestamp descending (newest first)
        // docs.sort((a, b) => (b['timestamp'] as Timestamp).compareTo(a['timestamp'] as Timestamp));

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final orderData = doc.data()! as Map<String, dynamic>;
            return _buildOrderCard(orderData, doc.id);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, String orderDocId) {
    final String orderIdDisplay = order['trackingNumber'] ?? orderDocId;

    // Safely handle timestamp
    final Timestamp? timestamp = order['timestamp'] as Timestamp?;
    final String dateDisplay = timestamp != null
        ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
        : 'N/A';

    // Safely handle items list
    final List<dynamic> items = order['items'] as List<dynamic>? ?? [];
    final firstItem = items.isNotEmpty ? items.first : null;

    final productName = firstItem?['name'] ?? 'Order Items';
    final imageUrl = firstItem?['imageUrl'] ?? '';
    final double totalAmount =
        (order['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final String status = order['orderStatus'] ?? 'Pending';

    // Status Color Logic
    Color statusColor = Colors.blue;
    if (status == 'Delivered') statusColor = Colors.green;
    if (status == 'Cancelled') statusColor = Colors.red;
    if (status.contains('Confirmed')) statusColor = Colors.orange;

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
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image),
                          ),
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
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
                      if (items.length > 1)
                        Text(
                          '+ ${items.length - 1} more items',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${totalAmount.toStringAsFixed(2)}',
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    // Pass the full order map to the receipt screen
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
                  child: const Text('View Receipt'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
