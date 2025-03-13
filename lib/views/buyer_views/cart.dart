import 'package:agribazar/controllers/buyer_controller/cart_controller.dart';
import 'package:agribazar/views/buyer_views/address_form.dart';
import 'package:agribazar/views/buyer_views/order_successfull.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Cart extends StatefulWidget {
  final User? user;
  const Cart({required this.user, super.key});
  @override
  CartState createState() => CartState();
}

class CartState extends State<Cart> {
  final CartController cartController = Get.put(CartController());

  @override
  void initState() {
    super.initState();
    cartController.calculateSubtotal();
    cartController.getCartItem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My cart",
          style: GoogleFonts.abhayaLibre(
            textStyle: const TextStyle(
                fontSize: 25, letterSpacing: .5, fontWeight: FontWeight.w700),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(child: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildCartItems(),
              const SizedBox(height: 20),
              _buildDeliveryOption(),
              const SizedBox(height: 20),
              _buildDeliveryDetails(),
              const SizedBox(height: 20),
              _buildPriceDetails(
                  cartController.subtotal.value, cartController.total.value),
            ],
          ),
        );
      })),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildPaymentButton(cartController.total.value),
      ),
    );
  }

  Widget _buildCartItems() {
    return Obx(() {
      if (cartController.cartProducts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart, size: 100, color: Colors.grey),
              const SizedBox(height: 20),
              Text(
                "Your cart is empty",
                style: GoogleFonts.abhayaLibre(
                  textStyle: const TextStyle(
                      fontSize: 20,
                      letterSpacing: .5,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      } else {
        return Column(
          children: cartController.cartProducts.asMap().entries.map((entry) {
            int index = entry.key;
            var product = entry.value;
            //print(product);
            return Column(
              children: [
                _buildCartItem(
                  index: index, // Pass index here
                  imageUrl: product['productImage'] ?? 'assets/splashImg.jpg',
                  title: product['productname'] ?? 'Unknown Product',
                  price: product['productPrice'] ?? 0.0,
                  quantity: product['quantity'] ?? 1,
                  onAdd: () {
                    cartController.updateQuantity(
                        index, product['quantity'] + 1);
                  },
                  onRemove: () {
                    if (product['quantity'] > 1) {
                      cartController.updateQuantity(
                          index, product['quantity'] - 1);
                    }
                  },
                ),
                const Divider(),
              ],
            );
          }).toList(),
        );
      }
    });
  }

  Widget _buildCartItem({
    required int index, // Add index parameter
    required String imageUrl,
    required String title,
    required double price,
    required int quantity,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    //double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Row(
          children: [
            Image.network(imageUrl, width: 50, height: 50,
                errorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/splashImg.jpg', width: 50, height: 50);
            }),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.abhayaLibre(
                      textStyle: const TextStyle(
                          fontSize: 19,
                          letterSpacing: .5,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Rs. $price',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.amber),
                  onPressed: onRemove,
                ),
                Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.amber),
                  onPressed: onAdd,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: screenWidth * 0.45,
                child: OutlinedButton(
                    onPressed: () {
                      cartController.removeCartItem(index);
                    },
                    child: Text(
                      'Remove',
                      style: GoogleFonts.abhayaLibre(
                        textStyle: const TextStyle(
                            fontSize: 18,
                            letterSpacing: .5,
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                      ),
                    ))),
            SizedBox(
                width: screenWidth * 0.45,
                child: OutlinedButton(
                    onPressed: () {},
                    child: Text(
                      'Order Now',
                      style: GoogleFonts.abhayaLibre(
                        textStyle: const TextStyle(
                            fontSize: 18,
                            letterSpacing: .5,
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                      ),
                    )))
          ],
        )
      ],
    );
  }

  Widget _buildDeliveryOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDeliveryTypeButton("Pickup", cartController.isPickup.value),
        _buildDeliveryTypeButton("Delivery", !cartController.isPickup.value),
      ],
    );
  }

  Widget _buildDeliveryTypeButton(String title, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          cartController.isPickup.value = title == "Pickup";
          cartController.calculateSubtotal();
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber : Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.abhayaLibre(
              textStyle: const TextStyle(
                  fontSize: 16,
                  letterSpacing: .5,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    if (cartController.cartProducts.isEmpty) {
      return const Center(
        child: Text("No products in the cart."),
      );
    }
    String address = cartController.cartProducts.first['address'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Delivery to",
          style: GoogleFonts.abhayaLibre(
            textStyle: const TextStyle(
                fontSize: 20,
                letterSpacing: .5,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                address,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "FedEx Express, Friday 28 July",
              style: TextStyle(fontSize: 14),
            ),
            GestureDetector(
              onTap: () {
                // Implement edit delivery option functionality
              },
              child: TextButton(
                  onPressed: () {
                    Get.to(EditAddressPage(user: widget.user!));
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.blue),
                  )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceDetails(double subtotal, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Price Details",
          style: GoogleFonts.abhayaLibre(
            textStyle: const TextStyle(
                fontSize: 20,
                letterSpacing: .5,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Subtotal"),
            Text("Rs. ${cartController.subtotal.value.toStringAsFixed(2)}"),
          ],
        ),
        const SizedBox(height: 8),
        if (!cartController.isPickup.value)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Delivery Charge"),
              Text(
                  "Rs. ${cartController.deliveryCharge.value.toStringAsFixed(2)}"),
            ],
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total",
              style: GoogleFonts.abhayaLibre(
                textStyle: const TextStyle(
                    fontSize: 18,
                    letterSpacing: .5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            Text(
              "Rs. ${cartController.total.value.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentButton(double total) {
    return ElevatedButton(
        onPressed: () {
          // Handle payment logic here
          Get.to(() => const OrderSuccessScreen());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Obx(
          () => Text(
            "Pay Now Rs. ${cartController.total.toStringAsFixed(2)}",
            style: GoogleFonts.abhayaLibre(
              textStyle: const TextStyle(
                  fontSize: 20,
                  letterSpacing: .5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ));
  }
}
