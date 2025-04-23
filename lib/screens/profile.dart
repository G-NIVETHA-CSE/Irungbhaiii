import 'package:flutter/material.dart';
import 'signup_screen.dart'; // Make sure this import is correct


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = "";
    _emailController.text = "";
    _phoneController.text = "";
    _addressController.text = "";
    _cityController.text = "";
    _pincodeController.text = "";
    _stateController.text = "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Widget _buildProfileItem({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          _isEditing
              ? TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.pink.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.pink.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: Colors.pink[50],
            ),
          )
              : Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.pink.shade200),
            ),
            child: Text(controller.text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("You are successfully logged out."),
        backgroundColor: Colors.red,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignUpScreen()),
      );
    });
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
                      ),
                      const SizedBox(width: 10),
                      const Text("Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isEditing ? Colors.pink : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_isEditing ? "Save" : "Edit", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Personal Info
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                      const SizedBox(height: 15),
                      _buildProfileItem(label: "Full Name", controller: _nameController),
                      _buildProfileItem(label: "Email Address", controller: _emailController, keyboardType: TextInputType.emailAddress),
                      _buildProfileItem(label: "Phone Number", controller: _phoneController, keyboardType: TextInputType.phone),
                    ],
                  ),
                ),

                // Address Info
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Address Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                      const SizedBox(height: 15),
                      _buildProfileItem(label: "Address", controller: _addressController, maxLines: 2),
                      _buildProfileItem(label: "City", controller: _cityController),
                      _buildProfileItem(label: "Pincode", controller: _pincodeController, keyboardType: TextInputType.number),
                      _buildProfileItem(label: "State", controller: _stateController),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Logout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
