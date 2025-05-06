import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'home.dart';
import 'home2.dart';

class MeatSpaPage extends StatefulWidget {
  const MeatSpaPage({super.key});

  @override
  State<MeatSpaPage> createState() => _MeatSpaPageState();
}

class _MeatSpaPageState extends State<MeatSpaPage> with SingleTickerProviderStateMixin {
  // Animation controllers
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _meatAnimation;
  late Animation<double> _salonAnimation;

  bool _isMeatHovered = false;
  bool _isSalonHovered = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create staggered animations with different delays
    _logoAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _textAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
    );

    _meatAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
    );

    _salonAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;
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
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  // Animated logo with fade and scale
                  FadeTransition(
                    opacity: _logoAnimation,
                    child: ScaleTransition(
                      scale: _logoAnimation,
                      child: Image.asset(
                        'assets/images/Logo.png',
                        width: 220,
                        height: 220,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Animated text with fade
                  FadeTransition(
                    opacity: _textAnimation,
                    child: const Text(
                      'Looking for',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      // Meat option with animation
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(_meatAnimation),
                        child: FadeTransition(
                          opacity: _meatAnimation,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isMeatHovered = true;
                              });

                              // Add a small delay to show the pulse animation
                              Future.delayed(const Duration(milliseconds: 300), () {
                                if (mounted) {
                                  setState(() {
                                    _isMeatHovered = false;
                                  });
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        var begin = const Offset(1.0, 0.0);
                                        var end = Offset.zero;
                                        var curve = Curves.easeInOut;
                                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                }
                              });
                            },
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: _isMeatHovered ? (Matrix4.identity()..scale(1.1)) : Matrix4.identity(),
                                  transformAlignment: Alignment.center,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
                                    child: Image.asset(
                                      'assets/images/meat.png',
                                      width: 180,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
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
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Salon option with animation
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(_salonAnimation),
                        child: FadeTransition(
                          opacity: _salonAnimation,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSalonHovered = true;
                              });

                              // Add a small delay to show the pulse animation
                              Future.delayed(const Duration(milliseconds: 300), () {
                                if (mounted) {
                                  setState(() {
                                    _isSalonHovered = false;
                                  });
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => Home2(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        var begin = const Offset(1.0, 0.0);
                                        var end = Offset.zero;
                                        var curve = Curves.easeInOut;
                                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                        return SlideTransition(
                                          position: animation.drive(tween),
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                }
                              });
                            },
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: _isSalonHovered ? (Matrix4.identity()..scale(1.1)) : Matrix4.identity(),
                                  transformAlignment: Alignment.center,
                                  child: Image.asset(
                                    'assets/images/salon.png',
                                    width: 180,
                                    height: 180,
                                  ),
                                ),
                                const SizedBox(height: 1),
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Animated Back button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const SignUpScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        var begin = const Offset(-1.0, 0.0);
                        var end = Offset.zero;
                        var curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
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