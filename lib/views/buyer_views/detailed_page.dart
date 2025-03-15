import 'package:agribazar/controllers/buyer_controller/cart_controller.dart';
import 'package:agribazar/controllers/buyer_controller/detail_controller.dart';
import 'package:agribazar/views/buyer_views/cart.dart';
import 'package:agribazar/views/buyer_views/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailPage extends StatefulWidget {
  final User? user;
  final String productId; // Pass the product ID from the previous screen

  const ProductDetailPage(
      {required this.user, required this.productId, super.key});

  @override
  ProductDetailPageState createState() => ProductDetailPageState();
}

class ProductDetailPageState extends State<ProductDetailPage> {
  CartController cartController = Get.put(CartController());
  late DetailController detailController;
  @override
  void initState() {
    super.initState();
    detailController = Get.put(
        DetailController(user: widget.user, productId: widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black),
            onPressed: () {
              Get.back();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.black),
              onPressed: () {
                // Action on cart button press
                Get.to(
                  Cart(
                    user: FirebaseAuth.instance.currentUser!,
                  ),
                );
              },
            ),
          ],
          elevation: 0,
        ),
        body: Obx(() {
          return Stack(children: [
            detailController.isLoading.value
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show a loading indicator
                : detailController.productDetails == null
                    ? Center(
                        child: Text(
                            'Error: ${detailController.errorMessage.value}')) // Show error if no data
                    : Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            Center(
                              child: Image.network(
                                fit: BoxFit.cover,
                                detailController
                                        .productDetails!['Crop Image'] ??
                                    "", // Fetch image URL from Firestore
                                height: screenHeight * 0.25,
                                width: screenWidth,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error,
                                      size: 80, color: Colors.red);
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Product Title, Rating, Weight, Price
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      detailController
                                              .productDetails!['Variety'] ??
                                          'Product Name', // Fetch crop name
                                      style: GoogleFonts.abhayaLibre(
                                        textStyle: const TextStyle(
                                            fontSize: 25,
                                            letterSpacing: .5,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Row(
                                      children: [
                                        Icon(Icons.star,
                                            color: Colors.yellow, size: 16),
                                        Icon(Icons.star,
                                            color: Colors.yellow, size: 16),
                                        Icon(Icons.star,
                                            color: Colors.yellow, size: 16),
                                        Icon(Icons.star_border,
                                            color: Colors.yellow, size: 16),
                                        Icon(Icons.star_border,
                                            color: Colors.yellow, size: 16),
                                        SizedBox(width: 8),
                                        Text('3.0'),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.remove_circle_outline),
                                          onPressed: () {
                                            if (detailController
                                                    .quantity.value >
                                                1) {
                                              detailController.quantity.value--;
                                            }
                                          },
                                        ),
                                        Obx(
                                          () => Text(
                                            '${detailController.quantity.value} kg',
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.add_circle_outline),
                                          onPressed: () {
                                            detailController.quantity.value++;
                                          },
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Rs.${detailController.productDetails!['Price']}', // Fetch price from Firestore
                                      style: GoogleFonts.poppins(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Description
                            Text(
                              'Description',
                              style: GoogleFonts.abhayaLibre(
                                textStyle: const TextStyle(
                                    fontSize: 22,
                                    letterSpacing: .5,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              detailController.productDetails!['Description'] ??
                                  'No description available.', // Fetch description from Firestore
                              style: GoogleFonts.abhayaLibre(
                                textStyle: const TextStyle(
                                    fontSize: 18,
                                    letterSpacing: .5,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Features',
                              style: GoogleFonts.abhayaLibre(
                                textStyle: const TextStyle(
                                    fontSize: 22,
                                    letterSpacing: .5,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              detailController.productDetails!['Features'] ??
                                  '',
                              style: GoogleFonts.abhayaLibre(
                                textStyle: const TextStyle(
                                    fontSize: 18,
                                    letterSpacing: .5,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const Spacer(),
                            // Add to Cart Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Action for adding to cart
                                  cartController.addCartItem(
                                      widget.productId,
                                      detailController
                                          .productDetails!['Variety'],
                                      detailController.productDetails!['Price'],
                                      detailController
                                          .productDetails!['Crop Image'],
                                      detailController
                                          .productDetails!['Address'],
                                      detailController
                                          .productDetails!['userId']);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.amber, // Button color
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Add to Cart',
                                  style: GoogleFonts.aclonica(
                                    textStyle: const TextStyle(
                                        fontSize: 16,
                                        letterSpacing: .5,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
            Positioned(
              bottom: 100, // Adjust to position above the Add to Cart button
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  if (detailController.productDetails != null &&
                      detailController.productDetails!.containsKey('userId') &&
                      detailController.productDetails!['userId'] != null) {
                    // Create chatRoomId if userId is available
                    detailController.chatRoomId.value =
                        "${widget.user!.uid}${detailController.productDetails!['userId']}";

                    Get.to(
                      ChatScreen(
                        userId: detailController.productDetails!['userId'],
                        chatRoomId: detailController.chatRoomId.value,
                      ),
                    );
                  } else {
                    // Handle the case where productDetails or userId is null
                    Get.snackbar('Warning',
                        'Cannot initiate chat. User information is missing.');
                  }
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.chat),
              ),
            ),
          ]);
        }));
  }
}
