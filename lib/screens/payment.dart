import 'package:flutter/material.dart';
import 'success.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';

class PaymentPage extends StatefulWidget {
  final double orderAmount;
  final List<Map<String, dynamic>> cartItems;
  final String? description;
  final String? voiceNotePath;

  const PaymentPage({
    Key? key,
    required this.orderAmount,
    required this.cartItems,
    this.description,
    this.voiceNotePath,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPayment = "Credit Card";
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isPlayerInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    await _player.openPlayer();
    setState(() {
      _isPlayerInitialized = true;
    });
  }

  Future<void> _playVoiceNote(String path) async {
    if (!_isPlayerInitialized) return;

    // Stop if already playing
    if (_isPlaying) {
      await _player.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
      return;
    }

    setState(() {
      _isPlaying = true;
    });

    await _player.startPlayer(
      fromURI: path,
      codec: Codec.aacADTS,
      whenFinished: () {
        setState(() {
          _isPlaying = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Order summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Order items list
              ...widget.cartItems.map((item) {
                // Fix: Use totalPrice directly from the item instead of calculating it
                double itemPrice = item['totalPrice'] ?? 0.0;

                // Fix: Remove the redundant "kg" in the weight display
                String weight = item['weight'] ?? '';
                if (weight.toLowerCase().endsWith('kg')) {
                  weight = weight; // Keep as is, already has kg
                } else {
                  weight = "${weight}kg"; // Add kg if not present
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${item['name']} (${weight})",
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        "Rs.${itemPrice.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const Divider(),

              // Order text note if exists
              if (widget.description != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Order Note:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.description!,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

              // Voice note if exists
              if (widget.voiceNotePath != null && File(widget.voiceNotePath!).existsSync())
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Voice Note:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          if (widget.voiceNotePath != null) {
                            _playVoiceNote(widget.voiceNotePath!);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                color: Colors.orange,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              const Text("Play voice note"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (widget.description != null || (widget.voiceNotePath != null && File(widget.voiceNotePath!).existsSync()))
                const Divider(),

              // Total amount
              summaryRow("Total:", "Rs.${widget.orderAmount.toStringAsFixed(2)}", isTotal: true),

              const SizedBox(height: 20),
              const Text(
                "Payment methods",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              paymentOption("assets/images/Credit.png", "Credit Card"),
              paymentOption("assets/images/debit.png", "Debit Card"),
              paymentOption("assets/images/upi.png", "UPI"),

              const SizedBox(height: 10),
              addNewPaymentOption(),

              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (value) {},
                    activeColor: Colors.orange,
                  ),
                  const Flexible(
                    child: Text("Save card details for future payments"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuccessPage(
                          cartItems: widget.cartItems,
                          totalAmount: widget.orderAmount,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Pay now",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget summaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.orange : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentOption(String imagePath, String paymentName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = paymentName;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedPayment == paymentName ? Colors.orange : Colors.transparent,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Text(
                      paymentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget addNewPaymentOption() {
    return GestureDetector(
      onTap: () {
        // Logic to add new payment method
      },
      child: Row(
        children: const [
          Icon(Icons.add_circle_outline, color: Colors.orange),
          SizedBox(width: 10),
          Text(
            "Add New Payment Option",
            style: TextStyle(color: Colors.orange, fontSize: 16),
          ),
        ],
      ),
    );
  }
}