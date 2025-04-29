import 'dart:async';
import 'package:flutter/material.dart';
import 'time.dart';

class SlotPage extends StatefulWidget {
  final String? selectedItemName;
  final String? selectedItemImage;
  final double? selectedItemPrice;
  final List<Map<String, dynamic>> cartItems;

  const SlotPage({
    super.key,
    this.selectedItemName,
    this.selectedItemImage,
    this.selectedItemPrice,
    this.cartItems = const [],
  });

  @override
  State<SlotPage> createState() => _SlotPageState();
}

class _SlotPageState extends State<SlotPage> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController unitController = TextEditingController(text: 'kg'); // Default unit

  final int initialPage = 1000; // Starting page for infinite scroll
  late final PageController _pageController;
  late Timer _timer;
  int _currentPage = 1000;

  List<String> imagePaths = [
    'assets/images/fish1.png',
    'assets/images/meat1.png',
    'assets/images/prawns1.png',
    'assets/images/mutton1.png',
  ];

  // Quick weight selection options with adjusted values
  final List<Map<String, dynamic>> quickWeightOptions = [
    {'value': '500', 'unit': 'g', 'label': '500g'},
    {'value': '1', 'unit': 'kg', 'label': '1kg'},
    {'value': '2', 'unit': 'kg', 'label': '2kg'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: initialPage);

    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    weightController.dispose();
    unitController.dispose();
    super.dispose();
  }

  // Calculate total price based on weight and unit
  double calculatePrice() {
    if (weightController.text.isEmpty) return 0.0;

    try {
      double weightValue = double.parse(weightController.text);
      double basePrice = widget.selectedItemPrice ?? 0.0;
      String unit = unitController.text.toLowerCase();

      double weightInGrams;

      // Convert to kg for calculation (price is per 250g)
      if (unit == 'kg') {
        weightInGrams = weightValue * 1000; // Convert kg to grams
      } else {
        weightInGrams = weightValue; // Already in grams
      }

      // Calculate price: base price (per 250g) * weight in kg * 4 (to get price per kg)
      return (weightInGrams / 250) * basePrice;
    } catch (e) {
      return 0.0;
    }
  }

  // Set weight and unit from quick selection
  void _setQuickWeight(String value, String unit, String label) {
    setState(() {
      weightController.text = value;
      unitController.text = unit;
    });
  }

  void _confirmSelection() {
    if (weightController.text.isNotEmpty) {
      // Calculate price based on weight and unit
      double totalPrice = calculatePrice();

      // Create weight string with unit
      String weightWithUnit = "${weightController.text} ${unitController.text}";

      // Navigate to time selection page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TimePage(
            selectedItemName: widget.selectedItemName,
            selectedItemImage: widget.selectedItemImage,
            selectedItemPrice: widget.selectedItemPrice,
            selectedWeight: weightWithUnit,
            totalPrice: totalPrice,
            cartItems: widget.cartItems,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter weight")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> weightUnits = ["kg", "g"];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        // Make the gradient fill the entire screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter, // Changed to bottomCenter to fill entire screen
            stops: [0.1, 1.0],
            colors: [Color(0xFFFFC0CB), Colors.white],
          ),
        ),
        child: SafeArea(
          // Use a Column with Expanded to manage layout
          child: Column(
            children: [
              // Scrollable content area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Select Weight",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                      ),

                      // Selected item info
                      if (widget.selectedItemName != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.pink[50],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.pink.shade200),
                          ),
                          child: Row(
                            children: [
                              if (widget.selectedItemImage != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    widget.selectedItemImage!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.selectedItemName!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(
                                      "Rs. ${widget.selectedItemPrice?.toStringAsFixed(2) ?? '0.00'} per 250g",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 10),

                      // Auto-scrolling image carousel with responsive height
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AspectRatio(
                            aspectRatio: 16/9, // Maintain aspect ratio for images
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                _currentPage = index;
                              },
                              itemBuilder: (context, index) {
                                final actualIndex = index % imagePaths.length;
                                return Container(
                                  color: Colors.grey[200], // Background color for images that don't fill space
                                  child: Image.asset(
                                    imagePaths[actualIndex],
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Weight selection section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Weight",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: TextField(
                                    controller: weightController,
                                    decoration: InputDecoration(
                                      labelText: "Weight",
                                      hintText: "Enter weight",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      filled: true,
                                      fillColor: Colors.pink[50],
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.pink[50],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.pink.shade200),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: unitController.text,
                                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                                        items: weightUnits.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              unitController.text = value;
                                            });
                                          }
                                        },
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Quick weight selection options
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Wrap(
                          spacing: 8,
                          children: quickWeightOptions.map((option) {
                            bool isSelected = weightController.text == option['value'] &&
                                unitController.text == option['unit'];
                            return InkWell(
                              onTap: () => _setQuickWeight(option['value'], option['unit'], option['label']),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.pink.shade300 : Colors.pink.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.pink.shade200),
                                ),
                                child: Text(
                                  option['label'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      if (weightController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Estimated Price: Rs. ${calculatePrice().toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ),

                      // Add some extra padding at the bottom for scroll spacing if needed
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Fixed confirm button at the bottom that doesn't scroll
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _confirmSelection,
                  child: const Text(
                    "Confirm",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}