import 'package:flutter/material.dart';
import 'slot.dart';
import 'payment.dart';
import 'order.dart';
import 'home.dart';

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

class _MeatPageState extends State<MeatPage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Show SnackBar for Order History (functionality to be added later)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order History feature coming soon!")),
      );
    } else if (index == 1) {
      // Navigate to MeatPage again (reload the page)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
          ),
      );
    } else if (index == 2) {
      // Show SnackBar for Profile
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile feature coming soon!")),
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
              Padding(
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
                            MaterialPageRoute(
                              builder: (context) => OrderPage(
                                initialCart: widget.cartItems,
                              ),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: Text(
                  "Timing: ${widget.shopTiming}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/images/meat2.jpeg', height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text("Description:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Perfect for a quick bite or a hearty meal, with deliciousness guaranteed.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text("Available Items:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.pink.shade200),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(items[index]["image"]!, width: 50, height: 50, fit: BoxFit.cover),
                        ),
                        title: Text(
                          items[index]["name"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        subtitle: Text(
                          items[index]["priceText"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SlotPage(
                                  selectedItemName: items[index]["name"],
                                  selectedItemImage: items[index]["image"],
                                  selectedItemPrice: items[index]["price"],
                                  cartItems: widget.cartItems,
                                ),
                              ),
                            );
                          },
                          child: const Text("Add", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    );
                  },
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
