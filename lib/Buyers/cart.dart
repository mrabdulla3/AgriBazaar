import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Cart extends StatefulWidget {
  final User? user;
  const Cart({required this.user, super.key});
  @override
  CartState createState() => CartState();
}

class CartState extends State<Cart> {
  List<Map<String, dynamic>> cartProducts = [];
  bool isPickup = false;
  double deliveryCharge = 30.00;

  @override
  void initState() {
    super.initState();
    getCartItem();
  }

  Future<void> getCartItem() async {
    try {
      QuerySnapshot cartItem = await FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.user!.uid)
          .collection('item')
          .get();

      setState(() {
        cartProducts = cartItem.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          double productPrice = (data['productPrice'] is int)
              ? (data['productPrice'] as int).toDouble()
              : (data['productPrice'] as double? ?? 0.0);

          return {
            'documentId': doc.id,
            'productImage': data['productImage'] ?? 'assets/splashImg.jpg',
            'address': data['address'] ?? '149, Sunset Ave, Los Angeles, CA',
            'productname': data['productname'] ?? 'Unknown Product',
            'productPrice': productPrice,
            'quantity': data['quantity'] is int ? data['quantity'] : 1,
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching cart items: $e");
    }
  }

  void removeCartItem(int index) async {
    try {
      String docId = cartProducts[index]['documentId'];
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(widget.user!.uid)
          .collection('item')
          .doc(docId)
          .delete();

      setState(() {
        cartProducts.removeAt(index);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Cart item removed')));
    } catch (e) {
      print("Error deleting cart item: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to remove item')));
    }
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = 0.0;
    for (var p in cartProducts) {
      double productPrice = p['productPrice'] * p['quantity'];
      subtotal += productPrice;
    }
    double total = subtotal + (isPickup ? 0 : deliveryCharge);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My cart",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              _buildPriceDetails(subtotal, total),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildPaymentButton(total),
      ),
    );
  }

  Widget _buildCartItems() {
    if (cartProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              "Your cart is empty",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: cartProducts.asMap().entries.map((entry) {
          int index = entry.key;
          var product = entry.value;
          return Column(
            children: [
              _buildCartItem(
                index: index, // Pass index here
                imageUrl: product['productImage'] ?? 'assets/splashImg.jpg',
                title: product['productname'] ?? 'Unknown Product',
                price: product['productPrice'] ?? 0.0,
                quantity: product['quantity'] ?? 1,
                onAdd: () {
                  setState(() {
                    product['quantity']++;
                  });
                },
                onRemove: () {
                  if (product['quantity'] > 1) {
                    setState(() {
                      product['quantity']--;
                    });
                  }
                },
              ),
              const Divider(),
            ],
          );
        }).toList(),
      );
    }
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
    return Row(
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
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Rs. $price',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon:
                  const Icon(Icons.remove_circle_outline, color: Colors.amber),
              onPressed: onRemove,
            ),
            Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.amber),
              onPressed: onAdd,
            ),
            IconButton(
              onPressed: () {
                removeCartItem(index); // Pass index here for deletion
              },
              icon: const Icon(
                Icons.delete,
                color: Color.fromARGB(255, 233, 18, 3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDeliveryTypeButton("Pickup", isPickup),
        _buildDeliveryTypeButton("Delivery", !isPickup),
      ],
    );
  }

  Widget _buildDeliveryTypeButton(String title, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isPickup = title == "Pickup";
          });
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
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    if (cartProducts.isEmpty) {
      return const Center(
        child: Text("No products in the cart."),
      );
    }
    String address = cartProducts.first['address'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Delivery to",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              address,
              style: const TextStyle(fontSize: 14),
            ),
            GestureDetector(
              onTap: () {
                // Implement edit address functionality
              },
              child: const Text(
                "Edit",
                style: TextStyle(color: Colors.blue, fontSize: 14),
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
              child: const Text(
                "Edit",
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
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
        const Text(
          "Price Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Subtotal"),
            Text("Rs. ${subtotal.toStringAsFixed(2)}"),
          ],
        ),
        const SizedBox(height: 8),
        if (!isPickup)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Delivery Charge"),
              Text("Rs. ${deliveryCharge.toStringAsFixed(2)}"),
            ],
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Total",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Rs. ${total.toStringAsFixed(2)}",
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
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        "Pay Now Rs. ${total.toStringAsFixed(2)}",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
