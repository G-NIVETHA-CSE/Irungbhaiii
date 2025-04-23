import 'package:flutter/material.dart';
import 'order.dart'; // Import OrderPage for navigation

class TimePage extends StatefulWidget {
  final String? selectedItemName;
  final String? selectedItemImage;
  final double? selectedItemPrice;
  final String? selectedWeight;
  final double? totalPrice;
  final List<Map<String, dynamic>> cartItems;

  const TimePage({
    super.key,
    this.selectedItemName,
    this.selectedItemImage,
    this.selectedItemPrice,
    this.selectedWeight,
    this.totalPrice,
    this.cartItems = const [],
  });

  @override
  State<TimePage> createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _confirmTimeSelection() {
    final formattedTime = selectedTime.format(context);

    final item = {
      'name': widget.selectedItemName,
      'image': widget.selectedItemImage,
      'price': widget.selectedItemPrice,
      'weight': widget.selectedWeight,
      'totalPrice': widget.totalPrice,
      'time': formattedTime,
    };

    final updatedCart = List<Map<String, dynamic>>.from(widget.cartItems)..add(item);

    // Calculate total order amount
    double totalOrderAmount = 0;
    for (var item in updatedCart) {
      totalOrderAmount += (item['totalPrice'] ?? 0.0);
    }

    // Navigating to OrderPage with the updatedCart and totalOrderAmount
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderPage(
          initialCart: updatedCart,
          totalOrderAmount: totalOrderAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime = selectedTime.format(context);

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
                      "Select Time",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
              ),

              // Item Box
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
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (widget.selectedWeight != null)
                              Text(
                                "Weight: ${widget.selectedWeight}",
                                style: const TextStyle(color: Colors.black87),
                              ),
                            if (widget.totalPrice != null)
                              Text(
                                "Total: Rs. ${widget.totalPrice!.toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                              ),
                            Text(
                              "Selected Time: $formattedTime",
                              style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // Time Picker UI
              Center(
                child: GestureDetector(
                  onTap: () => _selectTime(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      formattedTime,
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Confirm Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmTimeSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      "Confirm Time",
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