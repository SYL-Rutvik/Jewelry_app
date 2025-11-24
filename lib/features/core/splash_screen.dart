// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../auth/login_screen.dart'; // ✅ CHANGED: Import the LoginScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    // Simulate some loading time
    await Future.delayed(const Duration(milliseconds: 3000), () {});

    // Navigate to the LoginScreen and remove the SplashScreen from the stack
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ), // ✅ CHANGED: Navigate to LoginScreen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF77F38), // Orange background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your App Logo
            Image.asset(
              'assets/Sparkles.png', // Or your actual logo path
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              "Shine Bright", // Slogan or tagline
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
