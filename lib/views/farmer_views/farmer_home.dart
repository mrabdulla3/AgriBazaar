import 'package:agribazar/controllers/farmer_controller/farmer_home_controller.dart';
import 'package:agribazar/views/farmer_views/category_crops.dart';
import 'package:agribazar/views/farmer_views/chat_messageList.dart';
import 'package:agribazar/views/farmer_views/notifications.dart';
import 'package:agribazar/views/farmer_views/our_products.dart';
import 'package:agribazar/views/farmer_views/profile.dart';
import 'package:agribazar/views/authentication_views/authScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


class SellerDashboard extends StatefulWidget {
  final User? user;

  SellerDashboard({required this.user});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> {
  final farmerHomeController = Get.put(FarmerHomeController());

  @override
  void initState() {
    super.initState();
    farmerHomeController.getUserInfo(widget.user!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.off(() => AuthScreen());
            },
          ),
        ],
      ),
      body: Obx(() {
        if (farmerHomeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with user info
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.yellow[700],
                  child: Row(
                    children: [
                      Obx(() {
                        return CircleAvatar(
                          radius: 35,
                          backgroundImage: farmerHomeController.userProfileData.isNotEmpty &&
                                  farmerHomeController.userProfileData['profileImageUrl'] != null
                              ? NetworkImage(
                                      farmerHomeController.userProfileData['profileImageUrl'])
                                  as ImageProvider
                              : null,
                          child: farmerHomeController.userProfileData.isEmpty ||
                                  farmerHomeController.userProfileData['profileImageUrl']!=null
                              ? const Icon(Icons.person, size: 35)
                              : null,
                        );
                      }),
                      const SizedBox(width: 15),
                      Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmerHomeController.userProfileData['name'] ??
                                  widget.user!.displayName ??
                                  '',
                              style: GoogleFonts.abhayaLibre(
                                textStyle: const TextStyle(
                                    fontSize: 22,
                                    letterSpacing: .5,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(widget.user!.email ?? "",
                                style: GoogleFonts.abhayaLibre(
                                  textStyle: const TextStyle(
                                      fontSize: 18,
                                      letterSpacing: .5,
                                      fontWeight: FontWeight.w600),
                                )),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildEarningsCard('assets/order.jpg', 'Orders'),
                      buildEarningsCard('assets/wallet.png', 'Wallet'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildEarningsCard('assets/product.png', 'Products'),
                      buildEarningsCard('assets/statistics.png', 'Statistics'),
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
                      Text("Rating",
                          style: GoogleFonts.acme(
                            textStyle: const TextStyle(
                                fontSize: 20,
                                letterSpacing: .5,
                                fontWeight: FontWeight.w500),
                          )),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.yellow[700], size: 25),
                          Icon(Icons.star, color: Colors.yellow[700], size: 25),
                          Icon(Icons.star, color: Colors.yellow[700], size: 25),
                          Icon(Icons.star, color: Colors.yellow[700], size: 25),
                          Icon(Icons.star_half,
                              color: Colors.yellow[700], size: 25),
                          const SizedBox(width: 5),
                          const Text("4.0", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Government Price Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Government Price",
                    style: GoogleFonts.acme(
                      textStyle: const TextStyle(
                          fontSize: 20,
                          letterSpacing: .5,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      buildProductCard("Tomato", "30/kg", "assets/tomato.png"),
                      buildProductCard("Rice", "50/kg", "assets/rice.jpg"),
                      buildProductCard("Wheat", "50/kg", "assets/Wheat.jpg"),
                      buildProductCard("Fruits", "50/kg", "assets/fruits.jpg"),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      }),

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
                Get.to(() => SellerDashboard(user: widget.user));
              },
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.mail),
              onPressed: () {
                Get.to(() =>  ChatMessageFarmer());
              },
            ),
            label: 'Message',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.add_circle, size: 40),
              onPressed: () {
                Get.to(() => const CropCategoriesPage());
              },
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Get.to(() => const NotificationsFarmer());
              },
            ),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Get.to(() => ProfileFarmer(
                    user: FirebaseAuth.instance.currentUser!));
              },
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget buildEarningsCard(String imageUrl, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'Products') {
          Get.to(() => const OurProducts());
        } else if (label == 'Orders') {
          // Navigate to Orders Page
        } else if (label == 'Wallet') {
          // Navigate to Wallet Page
        } else if (label == 'Statistics') {
          // Navigate to Statistics Page
        }
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(imageUrl),
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: GoogleFonts.abhayaLibre(
                textStyle: const TextStyle(
                    fontSize: 19,
                    letterSpacing: .5,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProductCard(String name, String price, String imagePath) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(5),
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
            style: GoogleFonts.abhayaLibre(
              textStyle: const TextStyle(
                  fontSize: 19, letterSpacing: .5, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            price,
            style: GoogleFonts.abhayaLibre(
              textStyle: const TextStyle(fontSize: 15, letterSpacing: .5),
            ),
          ),
        ],
      ),
    );
  }
}
