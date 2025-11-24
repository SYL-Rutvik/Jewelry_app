import 'package:flutter/material.dart';

// 1. IMPORT THE FIREBASE CORE PACKAGE
import 'package:firebase_core/firebase_core.dart';
import 'package:jewelery_app/features/auth/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jewelery_app/features/auth/login_screen.dart';

// 2. IMPORT THE CONFIGURATION FILE YOU JUST GENERATED
import 'firebase_options.dart';

void main() async {
  // 3. ENSURE FLUTTER IS INITIALIZED
  WidgetsFlutterBinding.ensureInitialized();

  // 4. INITIALIZE FIREBASE
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 5. RUN YOUR APP
  runApp(const MyApp()); // Or whatever your main app widget is
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(), // <-- Set LoginScreen directly as home
    );
  }
}
