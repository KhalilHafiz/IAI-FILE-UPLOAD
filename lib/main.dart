import 'package:easy_upload/firebase_options.dart';
import 'package:easy_upload/screens/document_upload_page.dart';
import 'package:easy_upload/screens/home_page.dart';
import 'package:easy_upload/screens/login_page.dart';
import 'package:easy_upload/screens/signup_page.dart';
import 'package:easy_upload/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Only needed if using FlutterFire CLI
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',  // Default opening page
      routes: {
        '/home': (context) => HomePage(),  // Default route
        '/login': (context) => LoginPage(),
        '/': (context) => SplashScreen(),
        '/signup': (context) => SignupPage(),
        '/upload': (context) => DocumentUploadPage(),
      },
    );
  }
}

