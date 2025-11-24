import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  Future<void> _toggleSuspension(
    String userId,
    String email,
    bool currentStatus,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isSuspended': !currentStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User $email has been ${!currentStatus ? 'suspended' : 'activated'}.',
          ),
          backgroundColor: !currentStatus ? Colors.red : Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF77F38),
        title: const Text(
          'All Users',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Registered Users',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A3A3A),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHeaderRow(),
                    const Divider(height: 1, color: Colors.black12),

                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return const Text('Error');
                        if (snapshot.connectionState == ConnectionState.waiting)
                          return const CircularProgressIndicator();
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('No users found.'),
                          );

                        return Column(
                          children: snapshot.data!.docs.map((
                            DocumentSnapshot document,
                          ) {
                            Map<String, dynamic> user =
                                document.data()! as Map<String, dynamic>;
                            return _buildUserRow(user, document.id);
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    const headerStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black54,
      fontSize: 12,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: const [
          Expanded(flex: 3, child: Text('Name', style: headerStyle)),
          Expanded(flex: 5, child: Text('Email', style: headerStyle)),
          Expanded(
            flex: 4,
            child: Text(
              'Status / Action',
              style: headerStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user, String docId) {
    const cellStyle = TextStyle(color: Colors.black87, fontSize: 12);

    bool isSuspended = user['isSuspended'] == true;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              user['fullName'] ?? 'N/A',
              style: cellStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              user['email'] ?? 'N/A',
              style: cellStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 30,
                  width: 80,
                  child: ElevatedButton(
                    onPressed: () =>
                        _toggleSuspension(docId, user['email'], isSuspended),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSuspended
                          ? Colors.green.shade400
                          : Colors.red,
                      padding: EdgeInsets.zero,
                    ),
                    child: Text(
                      isSuspended ? 'Activate' : 'Disable',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
