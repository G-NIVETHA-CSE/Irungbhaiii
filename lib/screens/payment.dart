import 'package:flutter/material.dart';
import 'success.dart';

class PaymentPage extends StatefulWidget {
  final double orderAmount;
  final double taxes;

  const PaymentPage({
    Key? key,
    required this.orderAmount,
    required this.taxes,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPayment = "Credit Card";

  @override
  Widget build(BuildContext context) {
    double totalAmount = widget.orderAmount; // Removed taxes

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
              summaryRow("Order", "Rs.${widget.orderAmount.toStringAsFixed(2)}"),
              // Removed tax row
              const Divider(),
              summaryRow("Total:", "Rs.${totalAmount.toStringAsFixed(2)}", isTotal: true),
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
                      MaterialPageRoute(builder: (context) => const SuccessPage()),
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
            style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
          ),
          Text(
            value,
            style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal),
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
              return Center(child: Text("Image not found", style: TextStyle(color: Colors.red)));
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
