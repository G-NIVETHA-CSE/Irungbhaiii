import 'package:flutter/material.dart';

class Home2 extends StatelessWidget {
  const Home2({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> salonNames = [
      "Naturals Salon",
      "Green Glow Spa",
      "Urban Trends Salon",
      "Blush Beauty Bar",
      "Aura Hair Lounge",
      "The Royal Touch",
      "Elite Salon & Spa",
      "Mirror Mirror Salon",
      "Velvet Vibes Salon",
      "Tranquil Essence Spa",
      "Glow Up Studio",
      "The Glam Room",
      "Shear Magic Salon",
      "Lavender Luxe Spa",
      "Zenith Beauty Hub"
    ];

    List<String> salonTimings = [
      "5:00 am – 8:30 pm",
      "6:00 am – 9:00 pm",
      "7:00 am – 8:00 pm",
      "9:00 am – 7:00 pm",
      "10:00 am – 8:00 pm",
      "8:00 am – 9:00 pm",
      "7:30 am – 8:30 pm",
      "6:00 am – 10:00 pm",
      "9:30 am – 6:30 pm",
      "10:00 am – 9:00 pm",
      "8:30 am – 7:30 pm",
      "11:00 am – 8:00 pm",
      "7:00 am – 7:00 pm",
      "9:00 am – 9:00 pm",
      "6:30 am – 8:30 pm"
    ];


    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            stops: [0.1, 1.0],
            colors: [Colors.black, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Top bar: back, location, search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back + Location
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, size: 24, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.location_on, size: 24, color: Colors.red),
                        const SizedBox(width: 5),
                        const Text(
                          "Coimbatore",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    // Search bar
                    Container(
                      width: 150,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 5),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
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

              // Static Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/hair1.png',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Salon List
              Expanded(
                child: ListView.builder(
                  itemCount: salonNames.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade400),
                        boxShadow: [
                          BoxShadow(
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
                            'assets/images/hair2.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          salonNames[index],
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        subtitle: Text(
                          "Hours: ${salonTimings[index]}",
                          style: const TextStyle(color: Colors.black87),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
