// main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/navigation_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final NavigationService _navigationService = NavigationService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigationService.navigatorKey,
      home: SplashScreen(),
    );
  }
}