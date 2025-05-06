import 'package:flutter/material.dart';
import 'slot.dart';
import 'payment.dart';
import 'order.dart';
import 'home.dart';
import 'history.dart';
import 'profile.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MeatPage extends StatefulWidget {
  final String shopName;
  final String shopTiming;
  final List<Map<String, dynamic>> cartItems;

  const MeatPage({
    super.key,
    required this.shopName,
    required this.shopTiming,
    this.cartItems = const [],
  });

  @override
  State<MeatPage> createState() => _MeatPageState();
}

class _MeatPageState extends State<MeatPage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn)
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut)
    );

    // Start the animation when the page loads
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Navigate to Order History page
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HistoryPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(-1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      );
    } else if (index == 1) {
      // Navigate to HomePage
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else if (index == 2) {
      // Navigate to Profile page
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ProfilePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> items = [
      {
        "name": "Broiler Chicken",
        "price": 450.0,
        "priceText": "Rs. 450 per (250g)",
        "image": "assets/images/chicken1.png"
      },
      {
        "name": "Mutton",
        "price": 800.0,
        "priceText": "Rs. 800 per (250g)",
        "image": "assets/images/mutton.png"
      },
      {
        "name": "Country Chicken",
        "price": 600.0,
        "priceText": "Rs. 600 per (250g)",
        "image": "assets/images/chicken.png"
      },
      {
        "name": "Fish",
        "price": 300.0,
        "priceText": "Rs. 300 per (250g)",
        "image": "assets/images/fish.jpeg"
      },
      {
        "name": "Prawns",
        "price": 700.0,
        "priceText": "Rs. 700 per (250g)",
        "image": "assets/images/prawns.jpeg"
      },
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            stops: [0.1, 1.0],
            colors: [Color(0xFFFFC0CB), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated header
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.shopName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            if (widget.cartItems.isNotEmpty) {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => OrderPage(
                                    initialCart: widget.cartItems,
                                  ),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return FadeTransition(opacity: animation, child: child);
                                  },
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Your cart is empty")),
                              );
                            }
                          },
                          child: Badge(
                            isLabelVisible: widget.cartItems.isNotEmpty,
                            label: Text('${widget.cartItems.length}'),
                            child: const Icon(Icons.shopping_cart, size: 24, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    child: Text(
                      "Timing: ${widget.shopTiming}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                  ),
                ),
              ),

              // Animated banner image
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                                'assets/images/mutton1.png',
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Animated descriptions
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text("Description:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),

              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "Perfect for a quick bite or a hearty meal, with deliciousness guaranteed.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),

              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text("Available Items:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),

              // Animated list
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.pink[50],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.pink.shade200),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Fixed-size image container at the start
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      bottomLeft: Radius.circular(14),
                                    ),
                                    child: SizedBox(
                                      width: 80,
                                      height: 75, // Fixed height for the container
                                      child: Image.asset(
                                        items[index]["image"]!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  // Content and button
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  items[index]["name"]!,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  items[index]["priceText"]!,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Add button with pulse animation
                                          TweenAnimationBuilder(
                                            tween: Tween<double>(begin: 0.95, end: 1.0),
                                            duration: const Duration(milliseconds: 1000),
                                            curve: Curves.easeInOut,
                                            builder: (context, value, child) {
                                              return Transform.scale(
                                                scale: value,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      PageRouteBuilder(
                                                        pageBuilder: (context, animation, secondaryAnimation) => SlotPage(
                                                          selectedItemName: items[index]["name"],
                                                          selectedItemImage: items[index]["image"],
                                                          selectedItemPrice: items[index]["price"],
                                                          cartItems: widget.cartItems,
                                                        ),
                                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                          return FadeTransition(opacity: animation, child: child);
                                                        },
                                                      ),
                                                    );
                                                  },
                                                  child: const Text("Add", style: TextStyle(color: Colors.white)),
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
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Order History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.pink,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.transparent,
          elevation: 0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}