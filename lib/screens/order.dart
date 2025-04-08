import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'meatpage.dart';
import 'payment.dart';

class OrderPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialCart;

  const OrderPage({
    super.key,
    required this.initialCart,
  });

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late List<Map<String, dynamic>> cartItems;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecorderInitialized = false;
  int? _recordingItemIndex;

  @override
  void initState() {
    super.initState();
    cartItems = List.from(widget.initialCart);
    _initRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await _recorder.openRecorder();
    _isRecorderInitialized = true;
  }

  Future<void> _startRecording(int index) async {
    if (!_isRecorderInitialized) return;

    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/voice_note_$index.aac';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
    );

    setState(() {
      _recordingItemIndex = index;
    });
  }

  Future<void> _stopRecording(int index) async {
    if (!_isRecorderInitialized) return;

    String? path = await _recorder.stopRecorder();

    if (path != null) {
      setState(() {
        cartItems[index]['voiceNote'] = path;
        _recordingItemIndex = null;
      });
    }
  }

  void _toggleRecording(int index) async {
    if (_recordingItemIndex == index) {
      await _stopRecording(index);
    } else {
      await _startRecording(index);
    }
  }

  void _playVoiceNote(String path) async {
    FlutterSoundPlayer player = FlutterSoundPlayer();
    await player.openPlayer();
    await player.startPlayer(
      fromURI: path,
      codec: Codec.aacADTS,
      whenFinished: () {
        player.closePlayer();
      },
    );
  }

  void _addDescription(int index) {
    TextEditingController controller = TextEditingController(
      text: cartItems[index]['description'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Special Instructions'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add special cutting instructions or preferences...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                cartItems[index]['description'] = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  double calculateTotalAmount() {
    return cartItems.fold(0, (sum, item) {
      double itemPrice = item['price'] ?? 0.0;
      return sum + itemPrice;
    });
  }

  void removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = calculateTotalAmount();

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
                      "Your Cart",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
              ),

              cartItems.isEmpty
                  ? Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.pink[200]),
                      const SizedBox(height: 20),
                      const Text(
                        "Your cart is empty",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index];
                    double totalItemPrice = item["price"] ?? 0.0;
                    bool hasDescription = item['description'] != null && item['description'].isNotEmpty;
                    bool hasVoiceNote = item['voiceNote'] != null;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.pink.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(item["image"] ?? "assets/images/chicken.png", width: 50, height: 50, fit: BoxFit.cover),
                            ),
                            title: Text(
                              item["name"] ?? "Unknown Item",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                            subtitle: Text(
                              "Weight: ${item["weight"]}, Time: ${item["time"]}",
                              style: const TextStyle(color: Colors.black87),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeItem(index),
                            ),
                          ),

                          if (hasDescription)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Special Instructions:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['description'],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      hasDescription ? Icons.edit : Icons.add_comment,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    onPressed: () => _addDescription(index),
                                    tooltip: 'Add special instructions',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _recordingItemIndex == index ? Icons.stop : Icons.mic,
                                      color: _recordingItemIndex == index ? Colors.red : Colors.blue,
                                      size: 20,
                                    ),
                                    onPressed: () => _toggleRecording(index),
                                    tooltip: _recordingItemIndex == index ? 'Stop recording' : 'Record voice note',
                                  ),
                                  if (hasVoiceNote)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.play_arrow,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      onPressed: () => _playVoiceNote(item['voiceNote']),
                                      tooltip: 'Play voice note',
                                    ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Text(
                                  "Rs. ${totalItemPrice.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              if (cartItems.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.pink.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Subtotal:",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Rs. ${totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const Divider(thickness: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total:",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          Text(
                            "Rs. ${totalAmount.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MeatPage(
                                shopName: 'Fresh Meat Store',
                                shopTiming: '9:00 AM - 9:00 PM',
                                cartItems: cartItems,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Continue Shopping",
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: cartItems.isEmpty ? null : () {
                          double orderAmount = totalAmount;
                          double taxes = totalAmount * 0.05;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                  orderAmount: orderAmount,
                                  taxes: taxes
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Proceed to Pay",
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}