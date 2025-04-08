import 'package:flutter/material.dart';
import 'spa_page.dart';
import 'meatpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> shopList = [
    "Anisha Broilers",
    "Fresh Meat Hub",
    "Farm Fresh Chicken",
    "Quality Meat Market"
  ];

  List<String> shopTimings = [
    "6:00 am - 10:00 pm",
    "7:00 am - 9:00 pm",
    "6:30 am - 9:30 pm",
    "5:00 am - 11:00 pm"
  ];

  List<String> filteredShops = [];
  List<String> filteredTimings = [];
  TextEditingController searchController = TextEditingController();
  int _selectedIndex = 1; // Default to Home tab

  @override
  void initState() {
    super.initState();
    filteredShops = List.from(shopList);
    filteredTimings = List.from(shopTimings);
    searchController.addListener(_filterShops);
  }

  void _filterShops() {
    String query = searchController.text.toLowerCase();
    List<String> tempShops = [];
    List<String> tempTimings = [];

    for (int i = 0; i < shopList.length; i++) {
      if (shopList[i].toLowerCase().contains(query)) {
        tempShops.add(shopList[i]);
        tempTimings.add(shopTimings[i]);
      }
    }

    setState(() {
      filteredShops = tempShops;
      filteredTimings = tempTimings;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // You can add navigation to other pages when tabs are tapped
    // For now, we'll just update the selected index
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
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MeatSpaPage()),
                            );
                          },
                          child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.location_on, size: 24, color: Colors.red),
                        const SizedBox(width: 5),
                        const Text(
                          "Address",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),

                    // 🔍 Search Bar with filtering
                    Container(
                      width: 150,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 5),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search",
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/meat1.png',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 🧾 Filtered List
              Expanded(
                child: filteredShops.isEmpty
                    ? const Center(
                  child: Text("No shops found",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                )
                    : ListView.builder(
                  itemCount: filteredShops.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MeatPage(
                              shopName: filteredShops[index],
                              shopTiming: filteredTimings[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.pink[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.pink.shade200),
                          boxShadow: [
                            const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/chicken.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            filteredShops[index],
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          subtitle: Text(
                            "Hours: ${filteredTimings[index]}",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                        ),
                      ),
                    );
                  },
                ),
              ),
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