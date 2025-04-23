import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'home.dart'; // Import location page
import 'home2.dart';

class MeatSpaPage extends StatelessWidget {
  const MeatSpaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;

    // Decrease the extra height from 1/2 inch to 1/4 inch in logical pixels
    final quarterInchPixels = 40.0;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: screenSize.height + quarterInchPixels,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                stops: [0.1, 1.0],
                colors: [Color(0xFFFFC0CB), Colors.white],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80), // Add padding to make space for button
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Image.asset(
                      'assets/images/Logo.png',
                      width: 220,
                      height: 220,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Looking for',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/images/meat.png',
                                width: 160, // Increased from 140
                                height: 160, // Increased from 140
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Meat',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home2(),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/images/salon.png',
                                width: 180, // Increased from 160
                                height: 180, // Increased from 160
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Salon',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Go Back button at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 18, color: Colors.black),
                    SizedBox(width: 5),
                    Text(
                      'Go Back',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
