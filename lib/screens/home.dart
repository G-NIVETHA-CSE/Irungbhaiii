import 'package:flutter/material.dart';
import 'spa_page.dart';
import 'meatpage.dart';
import 'history.dart';
import 'profile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
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
  TextEditingController addressController = TextEditingController();
  int _selectedIndex = 1; // Default to Home tab
  String _userAddress = 'Address'; // Default address text
  bool _isLocationVisible = false; // To control the visibility of location details
  String _detailedLocation = ''; // To store detailed location information
  bool _isLoadingLocation = false; // To show loading indicator

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _isLocationVisible = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      setState(() {
        _detailedLocation = 'Location services are disabled. Please enable them.';
        _isLoadingLocation = false;
      });
      await Geolocator.openLocationSettings();
      return;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        setState(() {
          _detailedLocation = 'Location permission denied.';
          _isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      setState(() {
        _detailedLocation = 'Location permissions are permanently denied. Please enable in settings.';
        _isLoadingLocation = false;
      });
      return;
    }

    try {
      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );

      // Convert coordinates into a human-readable address
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        setState(() {
          _userAddress = '${place.locality}, ${place.administrativeArea}';
          _detailedLocation = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _detailedLocation = 'Error fetching location: $e';
        _isLoadingLocation = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    filteredShops = List.from(shopList);
    filteredTimings = List.from(shopTimings);
    searchController.addListener(_filterShops);

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

    // Start the animation when the page loads
    _animationController.forward();
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
      // Navigate to MeatPage again (reload the page)
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

  void _toggleLocationVisibility() {
    if (!_isLocationVisible) {
      _getCurrentLocation();
    } else {
      setState(() {
        _isLocationVisible = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    addressController.dispose();
    _animationController.dispose();
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
              // Animated header
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _toggleLocationVisibility,
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) => const MeatSpaPage(),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              return FadeTransition(opacity: animation, child: child);
                                            },
                                          ),
                                        );
                                      },
                                      child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.location_on, size: 24, color: Colors.red),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        _userAddress,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // 🔍 Search Bar with filtering
                            Container(
                              width: 200,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
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

                        // Location details section (appears below address)
                        if (_isLocationVisible)
                          Padding(
                            padding: const EdgeInsets.only(top: 5, left: 40),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _isLoadingLocation
                                  ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Fetching your location...'),
                                ],
                              )
                                  : Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _detailedLocation,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 16),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      // Show edit dialog
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          addressController.text = _detailedLocation;
                                          return AlertDialog(
                                            title: const Text('Edit Your Address'),
                                            content: TextField(
                                              controller: addressController,
                                              decoration: const InputDecoration(
                                                hintText: 'Type your address here',
                                                border: OutlineInputBorder(),
                                              ),
                                              maxLines: 2,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    if (addressController.text.trim().isNotEmpty) {
                                                      _detailedLocation = addressController.text.trim();
                                                    }
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.pink,
                                                ),
                                                child: const Text('Save'),
                                              ),
                                            ],
                                          );
                                        },
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
              const SizedBox(height: 10),

              // Animated banner image
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                              'assets/images/meat1.png',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filtered List with animations
              Expanded(
                child: filteredShops.isEmpty
                    ? const Center(
                  child: Text("No shops found",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                )
                    : AnimationLimiter(
                  child: ListView.builder(
                    itemCount: filteredShops.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => MeatPage(
                                      shopName: filteredShops[index],
                                      shopTiming: filteredTimings[index],
                                    ),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.pink[50],
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.pink.shade200),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
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
                                        height: 85, // Fixed height for the container
                                        child: Image.asset(
                                          'assets/images/hen.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    // Content with shop info
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
                                                    filteredShops[index],
                                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "Open: ${filteredTimings[index]}",
                                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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