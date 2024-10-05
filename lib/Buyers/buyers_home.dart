import 'package:agribazar/Buyers/cart.dart';
import 'package:agribazar/Buyers/category.dart';
import 'package:agribazar/Buyers/chat_message.dart';
import 'package:agribazar/Buyers/detailed_page.dart';
import 'package:agribazar/Buyers/notification.dart';
import 'package:agribazar/Buyers/pricing.dart';
import 'package:agribazar/Buyers/profile.dart';
import 'package:agribazar/Buyers/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MarketHomePage extends StatelessWidget {
  final User? user;

  const MarketHomePage({this.user, super.key});
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriBazaar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.mail),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatMessage(),
                  ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Notifications(),
                  ));
            },
          ),
        ],
      ),
      drawer: Sidebar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                      color: const Color.fromARGB(255, 113, 109, 109),
                      width: 2),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Top banner image
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/banner_image.png', // Replace with your asset image
                  height: screenHeight * 0.25,
                  width: screenWidth,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Category section
              const Text(
                "Category",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildCategoryItem("Vegetables", 'assets/veg.png'),
                  buildCategoryItem("Fruits", 'assets/fruits.png'),
                  buildCategoryItem("Rice", 'assets/rice.png'),
                  buildCategoryItem("Wheat", 'assets/wheat.png'),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              // Featured Products section
              const Text(
                "Featured Products",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildFeaturedProduct(
                      'Capsicum', 'assets/capsicum.png', 'Rs. 30/kg'),
                  buildFeaturedProduct(
                      'Wheat', 'assets/wheat.png', 'Rs. 30/kg'),
                ],
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MarketHomePage(),
                    ));
              },
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Cart(),
                    ));
              },
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.monetization_on),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Pricing(),
                    ));
              },
            ),
            label: 'Pricing',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile(),
                    ));
              },
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Function to build each category item
  Widget buildCategoryItem(String title, String imagePath) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => Categorys(),
            //     ));
          },
          child: CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(imagePath),
          ),
        ),
        const SizedBox(height: 5),
        Text(title),
      ],
    );
  }

  // Function to build each featured product
  Widget buildFeaturedProduct(String name, String imagePath, String price) {
    return SizedBox(
      width: 150,
      height: 220,
      child: GestureDetector(
        onTap: () {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => DetailedPage(),
          //     ));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              price,
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.brown),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
