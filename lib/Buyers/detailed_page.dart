import 'package:agribazar/Buyers/cart.dart';
import 'package:agribazar/Buyers/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailPage extends StatefulWidget {
  final User? user;
  final String productId; // Pass the product ID from the previous screen

  const ProductDetailPage(
      {required this.user, required this.productId, super.key});

  @override
  ProductDetailPageState createState() => ProductDetailPageState();
}

class ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  int cartItemCount = 0; // Add a cart item count
  String chatRoomId = "";

  Map<String, dynamic>? productDetails;
  bool isLoading = true;
  String errorMessage = '';

  // Function to fetch product details from Firestore
  Future<void> _getProductDetail() async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('FormCropDetail')
          .doc(widget
              .productId) // Use the passed productId to get specific product
          .get();

      setState(() {
        productDetails = productSnapshot.data() as Map<String, dynamic>?;
        isLoading = false;
      });
      // print(productDetails);
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching product details: $e';
        isLoading = false;
      });
      print('Error fetching product details: $e');
    }
  }

  Future<void> addCartItem(String productId, String productName, int price,
      String pImage, String address) async {
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.user!.uid)
          .collection('item')
          .add({
        'productid': productId,
        'productname': productName,
        'productPrice': price,
        'productImage': pImage,
        'quantity': 1,
        'address': address
      });
      setState(() {
        cartItemCount++; // Increment the cart item count
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item added to cart!')),
      );
    } catch (e) {
      print('Error adding item to cart: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getProductDetail(); // Fetch product details when the page initializes
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: () {
              // Action on cart button press
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cart(
                      user: FirebaseAuth.instance.currentUser!,
                    ),
                  ));
            },
          ),
        ],
        elevation: 0,
      ),
      body: Stack(children: [
        isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Show a loading indicator
            : productDetails == null
                ? Center(
                    child:
                        Text('Error: $errorMessage')) // Show error if no data
                : Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Center(
                          child: Image.network(
                            fit: BoxFit.cover,
                            productDetails!['Crop Image'] ??
                                "", // Fetch image URL from Firestore
                            height: screenHeight * 0.25,
                            width: screenWidth,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error,
                                  size: 80, color: Colors.red);
                            },
                            loadingBuilder: (context, child, loadingProgress) {
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
                                  productDetails!['Variety'] ??
                                      'Product Name', // Fetch crop name
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
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
                                        setState(() {
                                          if (quantity > 1) quantity--;
                                        });
                                      },
                                    ),
                                    Text(
                                      '$quantity kg',
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    IconButton(
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                      onPressed: () {
                                        setState(() {
                                          quantity++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  'Rs.${productDetails!['Price']}', // Fetch price from Firestore
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          productDetails!['Description'] ??
                              'No description available.', // Fetch description from Firestore
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Features',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          productDetails!['Features'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),

                        const Spacer(),

                        // Add to Cart Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Action for adding to cart
                              addCartItem(
                                  widget.productId,
                                  productDetails!['Variety'],
                                  productDetails!['Price'],
                                  productDetails!['Crop Image'],
                                  productDetails!['Address']);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.amber, // Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
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
              //print('Widget User ID: ${widget.user?.uid}'); // Debug print
              //print('Product User ID: ${productDetails?['userId']}'); // Debug print
              if (productDetails != null &&
                  productDetails!.containsKey('userId') &&
                  productDetails!['userId'] != null) {
                // Create chatRoomId if userId is available
                chatRoomId = "${widget.user!.uid}${productDetails!['userId']}";

                // Navigate to ChatScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      userId:
                          productDetails!['userId'], // Ensure this is not null
                      chatRoomId: chatRoomId,
                    ),
                  ),
                );
              } else {
                // Handle the case where productDetails or userId is null
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Cannot initiate chat. User information is missing.')),
                );
              }
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.chat),
          ),
        ),
      ]),
    );
  }
}
