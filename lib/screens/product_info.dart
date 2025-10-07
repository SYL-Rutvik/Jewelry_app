// lib/screens/product_info.dart
import 'package:flutter/material.dart';

class ProductInfoScreen extends StatelessWidget {
  const ProductInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// Builds the top app bar with navigation and actions.
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black54),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'DIAMOND RING',
        style: TextStyle(
          color: Color(0xFF3A3A3A),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.black54),
          onPressed: () {
            // TODO: Implement favorite functionality
          },
        ),
      ],
    );
  }

  /// Builds the main scrollable content of the screen.
  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. Product Image
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            // ⚠️ Make sure to add your product image to the `assets` folder
            // and declare it in `pubspec.yaml`.
            child: Image.asset(
              'assets/product_ring.png',
              height: 280,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),

          // 2. Product Title
          const Text(
            'Eluria Diamond Ring',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3A3A3A),
            ),
          ),
          const SizedBox(height: 25),

          // 3. Product Specifications
          _buildProductSpecs(),
          const SizedBox(height: 30),

          // 4. Description Card
          _buildDescriptionCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Builds the row for product specifications like weight and size.
  Widget _buildProductSpecs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSpecItem(Icons.scale_outlined, '7k'),
        _buildSpecItem(Icons.straighten_outlined, '4 cm'),
      ],
    );
  }

  /// Helper widget for a single specification item (icon + label).
  Widget _buildSpecItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 28),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 16)),
      ],
    );
  }

  /// Builds the styled container for the product description.
  Widget _buildDescriptionCard() {
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
      child: const Text(
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut.',
        textAlign: TextAlign.justify,
        style: TextStyle(
          color: Colors.black54,
          fontSize: 15,
          height: 1.6, // Line spacing for readability
        ),
      ),
    );
  }

  /// Builds the bottom navigation bar with price and "Add to Cart" button.
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 25),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Price
          const Text(
            '₹125',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3A3A3A),
            ),
          ),

          // Add to Cart Button
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement add to cart functionality
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add to Cart',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF77F38), // Primary orange color
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              shadowColor: const Color(0xFFF77F38).withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
