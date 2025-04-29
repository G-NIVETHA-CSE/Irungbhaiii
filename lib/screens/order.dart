import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'meatpage.dart';
import 'payment.dart';
import 'order_model.dart';

class OrderPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialCart;
  final double totalOrderAmount;

  const OrderPage({
    super.key,
    required this.initialCart,
    this.totalOrderAmount = 0.0,
  });

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late List<Map<String, dynamic>> cartItems;
  late double totalAmount;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;
  bool _isPlaying = false;
  String? _voiceNotePath;
  int? _voiceNoteDuration;
  DateTime? _voiceNoteDate;

  // For message input controller
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  String? _orderDescription;
  DateTime? _messageTime;

  // For WhatsApp-like recording animation
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  bool _showCancelSlider = false;
  bool _isRecording = false;
  double _cancelSlidePosition = 0.0;

  // For emoji reactions to descriptions
  List<String> emojiReactions = ['👍', '❤️', '😊', '😮', '😢', '🙏'];

  @override
  void initState() {
    super.initState();
    cartItems = List.from(widget.initialCart);
    totalAmount = widget.totalOrderAmount;
    _initRecorder();
    _initPlayer();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _recordingTimer?.cancel();
    _messageController.dispose();
    _messageFocusNode.dispose();
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

  Future<void> _initPlayer() async {
    await _player.openPlayer();
    _isPlayerInitialized = true;
  }

  String _formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _startRecording() async {
    if (!_isRecorderInitialized) return;

    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/voice_note_order.aac';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.aacADTS,
    );

    // Start timer for recording duration (WhatsApp-like)
    _recordingDuration = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });

    setState(() {
      _isRecording = true;
      _showCancelSlider = true;
      _cancelSlidePosition = 0.0;
    });
  }

  Future<void> _stopRecording({bool cancel = false}) async {
    if (!_isRecorderInitialized) return;

    _recordingTimer?.cancel();
    String? path = await _recorder.stopRecorder();

    setState(() {
      if (!cancel && path != null) {
        _voiceNotePath = path;
        _voiceNoteDuration = _recordingDuration;
        _voiceNoteDate = DateTime.now();
      }
      _isRecording = false;
      _showCancelSlider = false;
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

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _orderDescription = message;
        _messageTime = DateTime.now();
        _messageController.clear();
      });
    }
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Add emoji",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1,
                  ),
                  itemCount: emojiReactions.length,
                  itemBuilder: (context, i) {
                    return InkWell(
                      onTap: () {
                        _messageController.text += emojiReactions[i];
                        _messageController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _messageController.text.length),
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          emojiReactions[i],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void removeItem(int index) {
    setState(() {
      double itemPrice = cartItems[index]['totalPrice'] ?? 0.0;
      totalAmount -= itemPrice;
      cartItems.removeAt(index);
    });
  }

  String _formatMessageTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent keyboard from pushing up the layout
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

              // Main content area
              Expanded(
                child: cartItems.isEmpty
                    ? Center(
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
                )
                    : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Cart items in a single container
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.pink[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.pink.shade200),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartItems.length,
                          separatorBuilder: (context, index) => Divider(color: Colors.pink.shade200),
                          itemBuilder: (context, index) {
                            var item = cartItems[index];
                            double totalItemPrice = item["totalPrice"] ?? 0.0;

                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      item["image"] ?? "assets/images/chicken.png",
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Item details - expanded to take available space
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["name"] ?? "Unknown Item",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Weight: ${item["weight"]}, Time: ${item["time"]}",
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Price and delete button
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Rs. ${totalItemPrice.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => removeItem(index),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        iconSize: 22,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // Order note section (WhatsApp style) - Now per order, not per item
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECE5DD), // WhatsApp background color
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Add a note to your order",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Text message bubble (if exists)
                            if (_orderDescription != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCF8C6), // WhatsApp message bubble color
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _orderDescription!,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _messageTime != null ? _formatMessageTime(_messageTime!) : '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Voice message bubble (if exists)
                            if (_voiceNotePath != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCF8C6), // WhatsApp message bubble color
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (_voiceNotePath != null) {
                                          _playVoiceNote(_voiceNotePath!);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF00A884), // WhatsApp green
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _isPlaying ? Icons.stop : Icons.play_arrow,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 30,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: LinearProgressIndicator(
                                                value: _isPlaying ? 0.5 : 0, // Replace with actual progress
                                                backgroundColor: Colors.grey[300],
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  _isPlaying ? Colors.blue : Colors.grey[400]!,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          if (_voiceNoteDuration != null)
                                            Text(
                                              _formatDuration(_voiceNoteDuration!),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _voiceNoteDate != null ? _formatMessageTime(_voiceNoteDate!) : '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // WhatsApp-style input field
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  // Emoji button
                                  IconButton(
                                    icon: const Icon(Icons.emoji_emotions, color: Color(0xFF00A884)),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    iconSize: 24,
                                    onPressed: () => _showEmojiPicker(),
                                  ),
                                  const SizedBox(width: 8),

                                  // Text input field
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      focusNode: _messageFocusNode,
                                      decoration: const InputDecoration(
                                        hintText: "Type a message",
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                                      ),
                                      textCapitalization: TextCapitalization.sentences,
                                    ),
                                  ),

                                  // Send button
                                  IconButton(
                                    icon: const Icon(Icons.send, color: Color(0xFF00A884)),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    iconSize: 24,
                                    onPressed: () => _sendMessage(),
                                  ),
                                  const SizedBox(width: 4),

                                  // Voice recording button
                                  GestureDetector(
                                    onLongPress: () => _startRecording(),
                                    onLongPressEnd: (_) {
                                      if (_isRecording) {
                                        _stopRecording(cancel: _cancelSlidePosition > 100);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _isRecording
                                            ? Colors.red
                                            : const Color(0xFF00A884), // WhatsApp green
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _isRecording ? Icons.mic_off : Icons.mic,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Recording slider (appears when recording)
                            if (_showCancelSlider && _isRecording)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.arrow_back, color: Colors.red[700], size: 16),
                                    const SizedBox(width: 4),
                                    const Text(
                                      "Slide to cancel",
                                      style: TextStyle(color: Colors.red, fontSize: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Icon(Icons.mic, color: Colors.red[700], size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDuration(_recordingDuration),
                                            style: TextStyle(color: Colors.red[700], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Add extra space at the bottom for keyboard
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 300 : 0),
                    ],
                  ),
                ),
              ),

              // Fixed bottom section that stays at the bottom
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
                        onPressed: cartItems.isEmpty
                            ? null
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentPage(
                                orderAmount: totalAmount,
                                cartItems: cartItems,
                                description: _orderDescription,
                                voiceNotePath: _voiceNotePath,
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