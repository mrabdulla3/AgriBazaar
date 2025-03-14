import 'package:agribazar/controllers/buyer_controller/cart_controller.dart';
import 'package:agribazar/views/buyer_views/cart.dart';
import 'package:agribazar/views/buyer_views/detailed_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchProduct extends StatefulWidget {
  final User? user;
  List<Map<String, dynamic>> searchedList = [];
  SearchProduct({required this.user, super.key, required this.searchedList});

  @override
  State<SearchProduct> createState() => SearchProductState();
}

class SearchProductState extends State<SearchProduct> {
  CartController cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Searched Item",
          style: GoogleFonts.abyssinicaSil(
            textStyle: const TextStyle(
                fontSize: 20, letterSpacing: .5, fontWeight: FontWeight.w700),
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {
              Get.to(
                () => Cart(
                  user: FirebaseAuth.instance.currentUser!,
                ),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // GridView for displaying searched products
            widget.searchedList.isEmpty
                ? const Center(
                    child: Text("No items found",
                        style: TextStyle(color: Colors.red)),
                  )
                : GridView.builder(
                    shrinkWrap: true, // Make GridView take minimum space
                    physics:
                        const NeverScrollableScrollPhysics(), // Prevent GridView scrolling
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of items in a row
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.75, // Aspect ratio for the grid items
                    ),
                    itemCount: widget.searchedList.length,
                    itemBuilder: (context, index) {
                      final product = widget.searchedList[index];
                      return buildFeaturedProduct(
                        context,
                        product['Variety'],
                        product['Crop Image'],
                        product['Price'],
                        product['id'],
                        product['Address'],
                        product['userId'],
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

Widget buildFeaturedProduct(BuildContext context, String name, String imageUrl,
    int price, String productId, String address, String farmerId) {
  double screenHeight = MediaQuery.of(context).size.height;
  return GestureDetector(
    onTap: () {
      Get.to(
        () => ProductDetailPage(
          user: FirebaseAuth.instance.currentUser!,
          productId: productId,
        ),
      );
    },
    child: Card(
      elevation: 8, // Adds shadow intensity
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
      shadowColor: Colors.black.withOpacity(0.5), // Shadow color
      margin: const EdgeInsets.all(10), // Adds some margin around the card
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
              height: screenHeight * 0.15,
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.brown),
                  onPressed: () {
                    // Call addCartItem function to add product to cart
                    // Ensure SearchProductState is accessed
                    (context.findAncestorStateOfType<SearchProductState>())
                        ?.cartController
                        .addCartItem(productId, name, price, imageUrl, address,
                            farmerId);
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
