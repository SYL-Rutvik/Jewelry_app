import 'package:flutter/material.dart';
import 'product_info.dart';
import 'login_screen.dart';
import 'cart_page.dart';
import 'MyWishlist_screen.dart';

class HomeScreen extends StatefulWidget {
0  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Orange Header Box ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF77F38),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row with Menu + Cart Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Greeting Text
                  const Text(
                    "Hello, Rutvik",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "SPARKLES",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- Search Bar ---
                  _isSearching
                      ? Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              hintText: "Search Product",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (value) {
                              debugPrint("Searching for: $value");
                            },
                            onTapOutside: (_) {
                              setState(() {
                                _isSearching = false;
                              });
                            },
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSearching = true;
                            });
                          },
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: const [
                                SizedBox(width: 10),
                                Icon(Icons.search, color: Colors.grey),
                                SizedBox(width: 8),
                                Text(
                                  "Search Product",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Categories ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Categories",
                style: TextStyle(
                  color: Color(0xFF5F847C),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildCategoryChip("Ring", true),
                  const SizedBox(width: 10),
                  _buildCategoryChip("Necklace", false),
                  const SizedBox(width: 10),
                  _buildCategoryChip("Earring", false),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Trending Items ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Trending Items",
                style: TextStyle(
                  color: Color(0xFF5F847C),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.75,
                children: [
                  _buildProductCard(
                    "Diamond Ring",
                    "7 Carat (Gold)",
                    "₹125.00",
                    "https://i.imgur.com/fk6jB5G.png",
                  ),
                  _buildProductCard(
                    "Diamond Ring",
                    "10 Carat (Platinum)",
                    "₹125.00",
                    "https://i.imgur.com/5z6HhOa.png",
                  ),
                  _buildProductCard(
                    "Emerald Earring",
                    "",
                    "₹50.00",
                    "https://i.imgur.com/bYcPzS5.png",
                  ),
                  _buildProductCard(
                    "Sapphire Locket",
                    "",
                    "₹70.00",
                    "https://i.imgur.com/RW8Kn5x.png",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DRAWER WIDGETS ---

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: const Color(0xFFF6F6F6),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, size: 24),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      'My profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildUserInfoCard(),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF77F38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Options Card
            _buildOptionsCard(),
            const SizedBox(height: 40),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF77F38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/avatar.png'),
            ),
            SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rutvik',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('rutvik@gmail.com', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 4),
                Text('Rajkot, Gujrat', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildDrawerListTile(
              icon: Icons.shopping_cart_outlined,
              title: 'Cart',
              iconBackgroundColor: Colors.orange.shade300,
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
            ),
            _buildDrawerListTile(
              icon: Icons.favorite_border,
              title: 'My Wishlist',
              iconBackgroundColor: Colors.green.shade300,
              onTap: () {
                // ✅ UPDATE THIS ONTAP
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyWishlistScreen(),
                  ),
                );
              },
            ),
            _buildDrawerListTile(
              icon: Icons.shopping_bag_outlined,
              title: 'My Orders',
              iconBackgroundColor: Colors.pink.shade300,
              onTap: () {
                /* TODO: Implement Orders navigation */
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerListTile({
    required IconData icon,
    required String title,
    required Color iconBackgroundColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  // --- Other existing widgets ---
  // (Your _buildCategoryChip and _buildProductCard methods remain unchanged)
  Widget _buildCategoryChip(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF77F38) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF77F38)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFFF77F38),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProductCard(
    String title,
    String subtitle,
    String price,
    String imageUrl,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProductInfoScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                price,
                style: const TextStyle(
                  color: Color(0xFFF77F38),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
