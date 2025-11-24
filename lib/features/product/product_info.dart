import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cart/cart_page.dart';

class ProductInfoScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final String productId; // ✅ REQUIRED PRODUCT ID

  const ProductInfoScreen({
    Key? key,
    required this.product,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  bool _isFavorite = false;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  // Checks initial state of wishlist
  Future<void> _checkIfFavorite() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(widget.productId)
        .get();

    if (mounted) {
      setState(() {
        _isFavorite = doc.exists;
      });
    }
  }

  // Toggles the wishlist status (DELETE or SET)
  Future<void> _toggleFavorite() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please log in to add items to your wishlist."),
        ),
      );
      return;
    }

    final wishlistRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(widget.productId);

    if (_isFavorite) {
      await wishlistRef.delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Removed from wishlist.")));
    } else {
      await wishlistRef.set(widget.product);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Added to wishlist!")));
    }

    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
    }
  }

  // ADD TO CART LOGIC (Updates quantity if exists)
  Future<void> _addToCart() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please log in to add items to your cart."),
        ),
      );
      return;
    }

    try {
      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('cart')
          .doc(widget.productId);

      final cartDoc = await cartRef.get();

      if (cartDoc.exists) {
        // Item already exists, increment quantity
        final currentQuantity = (cartDoc.data()?['quantity'] ?? 0) as int;
        await cartRef.update({'quantity': currentQuantity + 1});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Quantity increased in cart!")),
        );
      } else {
        // Item is new, add it to cart with quantity 1
        await cartRef.set({
          ...widget.product, // Spread all product details
          'quantity': 1, // Add the quantity field
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Item added to cart!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add to cart: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract data safely from the map
    final product = widget.product;

    final String name = (product['name'] ?? 'Unknown Product') as String;
    final String price =
        '₹${(product['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}';
    final String description =
        (product['description'] ?? 'No description available.') as String;
    final String imageUrl = product['imageUrl'] as String? ?? '';

    final String karat = (product['karat'] ?? 'N/A') as String;
    final String weight = (product['weight'] ?? 'N/A') as String;
    final String size = (product['size'] ?? 'N/A') as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context, title: name),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Product Image
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                height: 280,
                width: double.infinity,
                child: (imageUrl.isNotEmpty)
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                            ? child
                            : const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                        errorBuilder: (context, error, stackTrace) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                            Text(
                              "Image unavailable",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 10),

            // 2. Product Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A3A3A),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 3. Dynamic Specifications (Karat, Weight, Size)
            _buildProductSpecs(karat, weight, size),

            const SizedBox(height: 30),

            // 4. Description
            _buildDescriptionCard(description),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, price),
    );
  }

  // --- HELPER WIDGETS ---

  AppBar _buildAppBar(BuildContext context, {required String title}) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black54),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF3A3A3A),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 16,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.black54,
          ),
          onPressed: _toggleFavorite,
        ),
      ],
    );
  }

  Widget _buildProductSpecs(String karat, String weight, String size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSpecItem(Icons.diamond_outlined, karat, "Karat"),
        _buildSpecItem(Icons.scale_outlined, weight, "Weight"),
        _buildSpecItem(Icons.straighten_outlined, size, "Size"),
      ],
    );
  }

  Widget _buildSpecItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Description",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3A3A3A),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, String price) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total Price",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A3A3A),
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: _addToCart, // Calls the async cart function
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            label: const Text(
              'Add to Cart',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF77F38),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
          ),
        ],
      ),
    );
  }
}
