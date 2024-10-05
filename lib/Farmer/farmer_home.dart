import 'package:agribazar/Farmer/category_crops.dart';
import 'package:agribazar/Farmer/chat_message.dart';
import 'package:agribazar/Farmer/notifications.dart';
import 'package:agribazar/Farmer/profile.dart';
import 'package:agribazar/user_authentication/authScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerDashboard extends StatelessWidget {
  final User user;

  const SellerDashboard({required this.user, super.key});
  @override
  Widget build(BuildContext context) {
    //double screenHeight = MediaQuery.of(context).size.height;
    //double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const AuthScreen(),
              ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.yellow[700],
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage(
                        'assets/user.png'), // Replace with user's image
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? "",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.email ?? "",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Earnings and Active Orders
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Your Earning",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "See more",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildEarningsCard('Rs. 5,000', 'Balance'),
                  buildEarningsCard('1 (Rs. 500)', 'Active Order'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rating
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Rating",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow[700], size: 25),
                      Icon(Icons.star, color: Colors.yellow[700], size: 25),
                      Icon(Icons.star, color: Colors.yellow[700], size: 25),
                      Icon(Icons.star, color: Colors.yellow[700], size: 25),
                      Icon(Icons.star_half,
                          color: Colors.yellow[700], size: 25),
                      const SizedBox(width: 5),
                      const Text(
                        "4.0",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Government Price Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Government Price",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  buildProductCard("Tomato", "30/kg",
                      "assets/tomato.png"), // Replace with your assets
                  buildProductCard("Potato", "50/kg", "assets/potato.png"),
                  buildProductCard("Onion", "50/kg", "assets/onion.png"),
                  buildProductCard("Capsicum", "50/kg", "assets/capsicum.png"),
                ],
              ),
            ),
          ],
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
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SellerDashboard(
                        user: user,
                      ),
                    ));
              },
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.mail),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatMessageFarmer(),
                    ));
              },
            ),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(
                Icons.add_circle,
                size: 40,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CropCategoriesPage(),
                    ));
              },
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsFarmer(),
                    ));
              },
            ),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileFarmer(),
                    ));
              },
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Widget to build earnings card
  Widget buildEarningsCard(String amount, String label) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            amount,
            style: const TextStyle(
                fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Widget to build product card
  Widget buildProductCard(String name, String price, String imagePath) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.asset(
            imagePath,
            height: 50,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            price,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
