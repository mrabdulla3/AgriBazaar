import 'package:agribazar/controllers/buyer_controller/cart_controller.dart';
import 'package:agribazar/controllers/buyer_controller/category_controller.dart';
import 'package:agribazar/views/buyer_views/cart.dart';
import 'package:agribazar/views/buyer_views/detailed_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';

class Categorys extends StatefulWidget {
  final User? user;
  String? cropType;
  Categorys({required this.user, super.key, required this.cropType});

  @override
  State<Categorys> createState() => _CategorysState();
}

final CartController cartController = Get.put(CartController());

class _CategorysState extends State<Categorys> {
  late CategoryController categoryController;

  @override
  void initState() {
    super.initState();
    categoryController = Get.put(
        CategoryController(user: widget.user, cropType: widget.cropType));
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
        body: SingleChildScrollView(child: Obx(() {
          return Column(
            children: [
              // GridView for displaying products
              if (categoryController.isLoading.value)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (categoryController.errorMessage.value.isNotEmpty)
                Center(
                  child: Text(categoryController.errorMessage.value,
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
                  itemCount: categoryController.productsList.length,
                  itemBuilder: (context, index) {
                    return buildCategoryProduct(
                      context,
                      categoryController.productsList[index]['Variety'],
                      categoryController.productsList[index]['Crop Image'],
                      categoryController.productsList[index]['Price'],
                      categoryController.productsList[index]['id'],
                      categoryController.productsList[index]['Address'],
                      categoryController.productsList[index]['userId'],
                    );
                  },
                ),
            ],
          );
        })));
  }
}

Widget buildCategoryProduct(BuildContext context, String name, String imageUrl,
    int price, String productId, String address, String farmerId) {
  double screenHeight = MediaQuery.of(context).size.height;
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
                    // Add to cart or handle other functionality
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
