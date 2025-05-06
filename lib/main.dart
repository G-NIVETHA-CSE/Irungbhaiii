import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/signup_screen.dart'; // Import your SignUpScreen
import 'screens/signup_page.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Initial route
      initialRoute: '/splash',
      // Define all your routes here
      routes: {
        '/splash': (context) => SplashScreen(),
        '/signup': (context) => SignUpScreen(),
        '/signup_page': (context) => SignUpPage(),
        // Add more routes as needed
      },
    );
  }
}