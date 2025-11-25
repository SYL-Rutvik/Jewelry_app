import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_users_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';
import 'admin_categories_screen.dart';
import '../auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF77F38),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      drawer: _buildAdminDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A3A3A),
                ),
              ),
              const SizedBox(height: 20),

              // --- ROW 1: ORDERS & REVENUE ---
              Row(
                children: [
                  // ✅ 1. DYNAMIC ORDERS CARD
                  _buildDynamicCountCard(
                    title: 'Total Orders',
                    collection: 'orders',
                    color: Colors.blue.shade600,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminOrdersScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // ✅ 2. DYNAMIC REVENUE CARD (Custom Logic)
                  _buildDynamicRevenueCard(
                    title: 'Revenue',
                    color: Colors.orange.shade600,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // --- ROW 2: PRODUCTS & CATEGORIES ---
              Row(
                children: [
                  _buildDynamicCountCard(
                    title: 'PRODUCTS',
                    collection: 'products',
                    color: Colors.green.shade600,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminProductsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildDynamicCountCard(
                    title: 'CATEGORIES',
                    collection: 'categories',
                    color: Colors.cyan.shade600,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminCategoriesScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // --- ROW 3: USERS ---
              Row(
                children: [
                  _buildDynamicCountCard(
                    title: 'USERS',
                    collection: 'users',
                    color: Colors.purple.shade600,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminUsersScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(),
                  ), // Empty spacer to keep alignment
                ],
              ),

              const SizedBox(height: 30),
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A3A3A),
                ),
              ),
              const SizedBox(height: 15),

              // ✅ 3. DYNAMIC RECENT ORDERS TABLE
              _buildRecentOrdersTable(),
            ],
          ),
        ),
      ),
    );
  }

  // --- DRAWER ---
  Widget _buildAdminDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFF77F38)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 30,
                    color: Color(0xFFF77F38),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Admin User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'admin@gmail.com',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Dynamic Count Card (Generic) ---
  Widget _buildDynamicCountCard({
    required String title,
    required String collection,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(collection)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    final int count = snapshot.data!.docs.length;
                    return Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET: Dynamic Revenue Card (Specific Logic) ---
  Widget _buildDynamicRevenueCard({
    required String title,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  // Calculate total revenue
                  double totalRevenue = 0;
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    // Check for 'totalAmount' or 'total' field (adjust based on your schema)
                    final amount = (data['totalAmount'] ?? data['total'] ?? 0);
                    // Safely convert to double
                    totalRevenue += (amount is int)
                        ? amount.toDouble()
                        : (amount as double);
                  }

                  return Text(
                    '₹${totalRevenue.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET: Recent Orders Table (Dynamic) ---
  Widget _buildRecentOrdersTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Table Header
            Row(
              children: const [
                Expanded(
                  child: Text(
                    'Order Id',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Customer',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Dynamic Rows
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('timestamp', descending: true)
                  .limit(5) // Only show the 5 most recent orders
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(),
                    ),
                  );
                if (snapshot.data!.docs.isEmpty)
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("No recent orders"),
                    ),
                  );

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildOrderRow(data, doc.id);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRow(Map<String, dynamic> order, String docId) {
    final String orderId = order['trackingNumber'] ?? docId.substring(0, 6);
    final String customer = order['deliveryAddress']?['fullName'] ?? 'Unknown';
    final String total = '₹${(order['totalAmount'] ?? 0).toString()}';
    final String status = order['orderStatus'] ?? 'Pending';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(orderId, overflow: TextOverflow.ellipsis)),
          Expanded(child: Text(customer, overflow: TextOverflow.ellipsis)),
          Expanded(child: Text(total, overflow: TextOverflow.ellipsis)),
          Expanded(
            child: Text(
              status,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _getStatusColor(status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Delivered') return Colors.green;
    if (status == 'Cancelled') return Colors.red;
    return Colors.blue;
  }
}
