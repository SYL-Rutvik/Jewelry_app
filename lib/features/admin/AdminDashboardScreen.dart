import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_users_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';
import 'admin_categories_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // --- Static data for now ---
  final int _totalOrders = 453;
  final double _revenue = 35786.00;

  final List<Map<String, dynamic>> _recentOrders = [
    {
      'orderId': '#12345',
      'customer': 'Rutvik',
      'total': '₹500',
      'status': 'Pending',
      'date': '05-11-2024',
    },
    {
      'orderId': '#12346',
      'customer': 'Rutvik',
      'total': '₹500',
      'status': 'Pending',
      'date': '05-11-2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF77F38),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
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
              Row(
                children: [
                  _buildDashboardCard(
                    title: 'Total Orders',
                    value: _totalOrders.toString(),
                    color: Colors.blue.shade600,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminOrdersScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildDashboardCard(
                    title: 'Revenue',
                    value: '₹${_revenue.toStringAsFixed(0)}',
                    color: Colors.orange.shade600,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildDynamicDashboardCard(
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
                  _buildDynamicDashboardCard(
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
              Row(
                children: [
                  // ✅ MODIFIED: The "USERS" card is now dynamic
                  _buildDynamicDashboardCard(
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
                  Expanded(child: Container()), // Empty space
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
              _buildRecentOrdersTable(),
            ],
          ),
        ),
      ),
    );
  }

  // --- This widget builds your dynamic cards ---
  Widget _buildDynamicDashboardCard({
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
                      return const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
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

  // --- This widget builds your static cards ---
  Widget _buildDashboardCard({
    required String title,
    required String value,
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
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrdersTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
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
                Expanded(
                  child: Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ..._recentOrders.map((order) => _buildOrderRow(order)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRow(Map<String, dynamic> order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(order['orderId']!)),
          Expanded(child: Text(order['customer']!)),
          Expanded(child: Text(order['total']!)),
          Expanded(child: Text(order['status']!)),
          Expanded(child: Text(order['date']!)),
        ],
      ),
    );
  }
}
