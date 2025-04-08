import 'dart:async';
import 'package:flutter/material.dart';
import 'order.dart';

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
  String? selectedTime;
  final TextEditingController weightController = TextEditingController();
  final TextEditingController unitController = TextEditingController(text: 'kg'); // Default unit

  final int initialPage = 1000; // Starting page for infinite scroll
  late final PageController _pageController;
  late Timer _timer;
  int _currentPage = 1000;

  List<String> imagePaths = [
    'assets/images/chicken.png',
    'assets/images/meat2.jpeg',
    'assets/images/fish.jpeg',
    'assets/images/meat1.png',
  ];

  // Quick weight selection options
  final List<Map<String, dynamic>> quickWeightOptions = [
    {'value': '0.25', 'unit': 'kg', 'label': '250g'},
    {'value': '0.5', 'unit': 'kg', 'label': '500g'},
    {'value': '0.75', 'unit': 'kg', 'label': '750g'},
    {'value': '1', 'unit': 'kg', 'label': '1kg'},
    {'value': '5', 'unit': 'kg', 'label': '5kg'},
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

      // Convert to kg for calculation (price is per 250g)
      if (unit == 'g') {
        // Convert grams to kg
        weightValue = weightValue / 1000;
      }

      // Calculate price: base price (per 250g) * weight in kg * 4 (to get price per kg)
      return basePrice * weightValue * 4;
    } catch (e) {
      return 0.0;
    }
  }

  // Set weight and unit from quick selection
  void _setQuickWeight(String value, String unit) {
    setState(() {
      weightController.text = value;
      unitController.text = unit;
    });
  }

  void _confirmSelection() {
    if (selectedTime != null && weightController.text.isNotEmpty) {
      // Calculate price based on weight and unit
      double totalPrice = calculatePrice();

      // Create weight string with unit
      String weightWithUnit = "${weightController.text} ${unitController.text}";

      // Create a new list that includes previous items plus the new one
      List<Map<String, dynamic>> updatedCart = List.from(widget.cartItems);

      // Add new item to cart
      updatedCart.add({
        "name": widget.selectedItemName ?? "Unknown Item",
        "image": widget.selectedItemImage ?? "assets/images/chicken.png",
        "weight": weightWithUnit,
        "time": selectedTime,
        "price": totalPrice,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderPage(
            initialCart: updatedCart,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a time slot and enter weight")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> timeSlots = [
      "5:00 am", "5:15 am", "5:30 am", "5:45 am",
      "6:00 am", "6:15 am", "6:30 am", "6:45 am",
      "7:00 am", "7:15 am", "7:30 am", "7:45 am",
      "8:00 am", "8:15 am", "8:30 am", "8:45 am",
      "9:00 am", "9:15 am", "9:30 am", "9:45 am",
      "10:00 am", "10:15 am", "10:30 am", "10:45 am",
      "11:00 am"
    ];

    List<String> weightUnits = ["kg", "g"];

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
                      "Select Time Slot",
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

              // Auto-scrolling image carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 160,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        _currentPage = index;
                      },
                      itemBuilder: (context, index) {
                        final actualIndex = index % imagePaths.length;
                        return Image.asset(
                          imagePaths[actualIndex],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  "Available: 5:00 AM - 11:00 AM",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Time",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.pink.shade200),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: selectedTime,
                    hint: const Text("Select Time", style: TextStyle(color: Colors.black, fontSize: 16)),
                    underline: Container(),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                    items: timeSlots.map((time) => DropdownMenuItem(value: time, child: Text(time))).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTime = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Weight",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
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
              ),

              // Quick weight selection options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: Wrap(
                  spacing: 8,
                  children: quickWeightOptions.map((option) {
                    return InkWell(
                      onTap: () => _setQuickWeight(option['value'], option['unit']),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (weightController.text == option['value'] &&
                              unitController.text == option['unit'])
                              ? Colors.pink.shade300
                              : Colors.pink.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.pink.shade200),
                        ),
                        child: Text(
                          option['label'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: (weightController.text == option['value'] &&
                                unitController.text == option['unit'])
                                ? Colors.white
                                : Colors.black87,
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
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}