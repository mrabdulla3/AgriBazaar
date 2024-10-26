import 'package:agribazar/Buyers/cart.dart';
import 'package:agribazar/Buyers/detailed_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Categorys extends StatefulWidget {
  final User? user;
  String? cropType;
  Categorys({required this.user, super.key, required this.cropType});

  @override
  State<Categorys> createState() => _CategorysState();
}

class _CategorysState extends State<Categorys> {
  List<Map<String, dynamic>> productsList = [];
  String errorMessage = '';
  bool isLoading = true;
  int cartItemCount = 0; // Add a cart item count

  Future<void> _getCrops(String category) async {
    try {
      QuerySnapshot cropSnapshot = await FirebaseFirestore.instance
          .collection('FormCropDetail')
          .where('cropType', isEqualTo: category)
          .get();
      setState(() {
        productsList = cropSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
      //print(productsList);
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching crops for $category: $e';
        isLoading = false;
      });
      print('Error fetching crops: $e');
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
        'address': address,
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
    _getCrops(widget.cropType!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.cropType ?? "Categories Item",
            style: const TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.black),
              onPressed: () {
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              // GridView for displaying products
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (errorMessage.isNotEmpty)
                Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)),
                )
              else
                GridView.builder(
                  shrinkWrap:
                      true, // This will make the GridView take minimum space
                  physics:
                      const NeverScrollableScrollPhysics(), // Prevent scrolling inside GridView
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of items in a row
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.75, // Aspect ratio for the grid items
                  ),
                  itemCount: productsList.length,
                  itemBuilder: (context, index) {
                    return buildFeaturedProduct(
                      context,
                      productsList[index]['Variety'],
                      productsList[index]['Crop Image'],
                      productsList[index]['Price'],
                      productsList[index]['id'],
                      productsList[index]['Address'],
                    );
                  },
                ),
            ],
          ),
        ));
  }
}

Widget buildFeaturedProduct(BuildContext context, String name, String imageUrl,
    int price, String productId, String address) {
  double screenHeight = MediaQuery.of(context).size.height;
  return GestureDetector(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProductDetailPage(
                    user: FirebaseAuth.instance.currentUser!,
                    productId: productId,
                  )));
    },
    child: Expanded(
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
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.brown),
                    onPressed: () {
                      // Add to cart or handle other functionality
                      //addCartItem(productId, name, price, imageUrl, address);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}
