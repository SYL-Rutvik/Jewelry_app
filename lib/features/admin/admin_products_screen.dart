import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_product_screen.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);

  void _confirmAndDeleteProduct(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to permanently delete this product? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                try {
                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(docId)
                      .delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete product: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
          'ADMIN',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
        backgroundColor: const Color(0xFFF77F38),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Products',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A3A3A),
                ),
              ),
              const SizedBox(height: 20),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.all(12.0),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderRow(),
                      const Divider(height: 1, color: Colors.black12),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('products')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('No products found. Add one!'),
                            );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: snapshot.data!.docs.map((
                              DocumentSnapshot document,
                            ) {
                              Map<String, dynamic> product =
                                  document.data()! as Map<String, dynamic>;
                              return _buildProductRow(
                                product,
                                document.id,
                                context,
                                _confirmAndDeleteProduct,
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black54,
      fontSize: 12,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          const SizedBox(width: 60, child: Text('Image', style: style)),
          const SizedBox(width: 150, child: Text('Product Name', style: style)),
          const SizedBox(width: 50, child: Text('Price', style: style)),
          const SizedBox(width: 50, child: Text('Stock', style: style)),
          const SizedBox(width: 70, child: Text('Category', style: style)),
          const SizedBox(
            width: 120,
            child: Text('Actions', style: style, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(
    Map<String, dynamic> product,
    String docId,
    BuildContext context,
    Function(BuildContext, String) onDelete,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            child: (product['imageUrl'] != null)
                ? Image.network(
                    product['imageUrl'],
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  )
                : Container(height: 40, width: 40, color: Colors.grey[200]),
          ),
          SizedBox(
            width: 150,
            child: Text(
              product['name'] ?? 'N/A',
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              '₹${product['price']?.toStringAsFixed(0) ?? '0'}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              product['stockQuantity']?.toString() ?? '0',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              product['category'] ?? 'N/A',
              style: const TextStyle(fontSize: 12),
            ),
          ),

          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  text: 'Edit',
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProductScreen(
                          productId: docId,
                          initialData: product,
                        ),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  text: 'Delete',
                  color: Colors.red,
                  onPressed: () => onDelete(context, docId),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 24,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}
