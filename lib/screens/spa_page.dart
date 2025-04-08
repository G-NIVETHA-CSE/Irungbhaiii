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
    // Assuming a standard pixel density of ~160 dpi, 1/4 inch ≈ 40 logical pixels
    final quarterInchPixels = 40.0;

    return Scaffold(
      body: Container(
        // Make container take slightly less than full width
        width: double.infinity,
        // Set minimum height to slightly less than current value
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30), // Decreased from 35
              Center(
                child: Image.asset(
                  'assets/images/Logo.png',
                  width: 220, // Decreased from 240
                  height: 220, // Decreased from 240
                ),
              ),
              const SizedBox(height: 12), // Decreased from 15
              const Text(
                'Looking for',
                style: TextStyle(
                  fontSize: 28, // Decreased from 30
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12), // Decreased from 15
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
                        Image.asset(
                          'assets/images/meat.png',
                          width: 140, // Decreased from 150
                          height: 140, // Decreased from 150
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Meat',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18, // Decreased from 20
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12), // Decreased from 15
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
                        Image.asset(
                          'assets/images/salon.png',
                          width: 160, // Decreased from 170
                          height: 160, // Decreased from 170
                        ),
                        const SizedBox(height: 4), // Decreased from 5
                        const Text(
                          'Salon',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20, // Decreased from 22
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20), // Decreased from 25
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 18, color: Colors.black), // Decreased from 20
                    SizedBox(width: 5), // Decreased from 6
                    Text(
                      'Go Back',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15, // Decreased from 16
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8), // Decreased from 10
            ],
          ),
        ),
      ),
    );
  }
}