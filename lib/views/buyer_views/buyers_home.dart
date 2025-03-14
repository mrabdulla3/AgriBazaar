import 'package:agribazar/controllers/buyer_controller/cart_controller.dart';
import 'package:agribazar/controllers/buyer_controller/home_controller.dart';
import 'package:agribazar/views/buyer_views/cart.dart';
import 'package:agribazar/views/buyer_views/category.dart';
import 'package:agribazar/views/buyer_views/chat_userlist.dart';
import 'package:agribazar/views/buyer_views/detailed_page.dart';
import 'package:agribazar/views/buyer_views/notification.dart';
import 'package:agribazar/views/buyer_views/pricing.dart';
import 'package:agribazar/views/buyer_views/profile.dart';
import 'package:agribazar/views/buyer_views/sidebar.dart';
import 'package:agribazar/views/authentication_views/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketHomePage extends StatelessWidget {
  final User? user;
  final HomeController homeController = Get.put(HomeController());
  final CartController cartController = Get.put(CartController());

  MarketHomePage({this.user, super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AgriBazaar',
          style: GoogleFonts.abrilFatface(
            textStyle: const TextStyle(fontSize: 18, letterSpacing: .5),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.mail),
            onPressed: () {
              Get.to(const ChatMessageBuyer());
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Get.to(const Notifications());
            },
          ),
        ],
      ),
      drawer: Sidebar(
        user: user!,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar with a button
              Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                      color: const Color.fromARGB(255, 113, 109, 109),
                      width: 1),
                ),
                child: TextField(
                  controller: homeController.searchController,
                  onSubmitted: (value) {
                    homeController.searchQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: "Search...",
                    hintStyle: GoogleFonts.abhayaLibre(
                      textStyle: const TextStyle(
                          fontSize: 16,
                          letterSpacing: .5,
                          fontWeight: FontWeight.w600),
                    ),
                    border: InputBorder.none,
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.black),
                      onPressed: () {
                        homeController
                            .searchQuery(homeController.searchController.text);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(height: screenHeight * 0.03),

              // Top banner image
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/splashImg.jpg',
                  height: screenHeight * 0.2,
                  width: screenWidth,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Category section
              Text(
                "Category",
                style: GoogleFonts.aboreto(
                  textStyle: const TextStyle(
                      fontSize: 18,
                      letterSpacing: .5,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildCategoryItem("Vegetables", 'assets/tomato.png'),
                  buildCategoryItem("Fruits", 'assets/fruits.jpg'),
                  buildCategoryItem("Rice", 'assets/rice.jpg'),
                  buildCategoryItem("Wheat", 'assets/Wheat.jpg'),
                  buildCategoryItem("Maize", 'assets/maize.jpg'),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              // Featured Products section with GridView
              Text(
                "Featured Products",
                style: GoogleFonts.aboreto(
                  textStyle: const TextStyle(
                      fontSize: 18,
                      letterSpacing: .5,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),

              // GridView for displaying products
              Obx(() {
                if (homeController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (homeController.errorMessage.isNotEmpty) {
                  return Center(
                      child: Text(homeController.errorMessage.value,
                          style: const TextStyle(color: Colors.red)));
                } else {
                  return GridView.builder(
                    shrinkWrap:
                        true, // This will make the GridView take minimum space
                    physics:
                        const NeverScrollableScrollPhysics(), // Prevent scrolling inside GridView
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of items in a row
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.75, // Aspect ratio for the grid items
                    ),
                    itemCount: homeController.featuredProducts.length,
                    itemBuilder: (context, index) {
                      //print(homeController.featuredProducts[index]['Crop Image']);
                      return buildFeaturedProduct(
                          homeController.featuredProducts[index]['Variety'],
                          homeController.featuredProducts[index]['Crop Image'],
                          homeController.featuredProducts[index]['Price'],
                          homeController.featuredProducts[index]['id'],
                          homeController.featuredProducts[index]['Address'],
                          homeController.featuredProducts[index]['userId']);
                    },
                  );
                }
              })
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
              icon: const Icon(Icons.home),
              onPressed: () {
                Get.to(() => MarketHomePage());
              },
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Get.to(
                  () => Cart(
                    user: user!,
                  ),
                );
              },
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.monetization_on),
              onPressed: () {
                Get.to(() => const Pricing());
              },
            ),
            label: 'Pricing',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                if (user != null) {
                  Get.to(
                    () => Profile(
                      user: user!, // Pass the user if not null
                    ),
                  );
                } else {
                  // Navigate to the signup page if user is null
                  Get.to(SignUpPage());
                }
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
            //Handle navigation to category page
            Get.to(Categorys(user: user!, cropType: title));
          },
          child: CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(imagePath),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: GoogleFonts.aboreto(
            textStyle: const TextStyle(
                fontSize: 10, letterSpacing: .5, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Function to build each featured product
  Widget buildFeaturedProduct(String name, String imageUrl, int price,
      String productId, String address, String farmerId) {
    double screenHeight = Get.height;
    return GestureDetector(
      onTap: () {
        Get.to(ProductDetailPage(
          user: FirebaseAuth.instance.currentUser!,
          productId: productId,
        ));
      },
      child: Card(
        elevation: 8, // Adds shadow intensity
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        shadowColor: Colors.black.withOpacity(0.5), // Shadow color
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.network(
                imageUrl,
                height: screenHeight * 0.13,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error,
                      size: 80,
                      color: Colors.red,
                    ),
                  ); // Handle error if image fails to load
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                name,
                style: GoogleFonts.abhayaLibre(
                  textStyle: const TextStyle(
                      fontSize: 19,
                      letterSpacing: .5,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$price /kg',
                    style: GoogleFonts.abhayaLibre(
                        textStyle: const TextStyle(
                            fontSize: 19,
                            letterSpacing: .5,
                            fontWeight: FontWeight.w600),
                        color: const Color.fromARGB(255, 64, 176, 68)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.brown),
                    onPressed: () {
                      // Add to cart or handle other functionality
                      //print("Home : ${homeController.featuredProducts}");

                      cartController.addCartItem(
                          productId, name, price, imageUrl, address, farmerId);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
