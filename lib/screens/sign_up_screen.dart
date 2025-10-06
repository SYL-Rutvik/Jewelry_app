import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart'; // ✅ Import your actual LoginScreen

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double statusBar = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF5F847C),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Header Section ---
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: screenSize.width,
                  height: screenSize.height * 0.35,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF77F38),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: screenSize.height * 0.05),
                        Image.network(
                          'https://i.imgur.com/Gj3H6k0.png',
                          height: 60,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'SPARKLES',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  left: screenSize.width / 2 - 120,
                  child: Image.asset(
                    'assets/ring.webp',
                    height: 200,
                    width: 240,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: statusBar + 16,
                  left: 20,
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenSize.height * 0.12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Input fields
                  _buildTextField('Full Name', Icons.person),
                  const SizedBox(height: 20),
                  _buildTextField('Email', Icons.email),
                  const SizedBox(height: 20),
                  _buildTextField('Password', Icons.lock, obscureText: true),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Confirm Password',
                    Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 40),

                  // Sign Up button
                  _buildSignUpButton(context, screenSize),
                  const SizedBox(height: 20),

                  // --- Sign In Link (Clickable) ---
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          TextSpan(
                            text: 'Sign in',
                            style: const TextStyle(
                              color: Color(0xFFF77F38),
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // ✅ Navigate to your real LoginScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
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
          ],
        ),
      ),
    );
  }

  // Input field widget
  Widget _buildTextField(
    String hintText,
    IconData icon, {
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Sign Up button
  Widget _buildSignUpButton(BuildContext context, Size screenSize) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFF77F38), Color(0xFFFC5C4B)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF77F38).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            debugPrint('Sign Up Button Pressed!');
          },
          child: const Center(
            child: Text(
              'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
