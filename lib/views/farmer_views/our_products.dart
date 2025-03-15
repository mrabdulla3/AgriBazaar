import 'package:agribazar/controllers/farmer_controller/our_products_controller.dart';
import 'package:agribazar/views/farmer_views/edit_product.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class OurProducts extends StatefulWidget {
  const OurProducts({super.key});

  @override
  State<OurProducts> createState() => _OurProductsState();
}

class _OurProductsState extends State<OurProducts> {
  final ourProductController = Get.put(OurProductsController());

  @override
  void initState() {
    super.initState();
    ourProductController.getOurProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Our Products',
              style: GoogleFonts.abhayaLibre(
                textStyle: const TextStyle(
                    fontSize: 22,
                    letterSpacing: .5,
                    fontWeight: FontWeight.w600),
              )),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ourProductController.isLoading.value)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (ourProductController.errorMessage.value.isNotEmpty)
                    Center(
                      child: Text(ourProductController.errorMessage.value,
                          style: const TextStyle(color: Colors.red)),
                    )
                  else
                    GridView.builder(
                      shrinkWrap:
                          true, // This will make the GridView take minimum space
                      physics:
                          const NeverScrollableScrollPhysics(), // Prevent scrolling inside GridView
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of items in a row
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio:
                            0.75, // Aspect ratio for the grid items
                      ),
                      itemCount: ourProductController.productList.length,
                      itemBuilder: (context, index) {
                        return buildProducts(
                          context,
                          ourProductController.productList[index]['Variety'],
                          ourProductController.productList[index]['Crop Image'],
                          ourProductController.productList[index]['Price'],
                          ourProductController.productList[index]['id'],
                          ourProductController.productList[index]['Address'],
                        );
                      },
                    ),
                ],
              )),
        )));
  }

  Widget buildProducts(BuildContext context, String name, String imageUrl,
      int price, String productId, String address) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Card(
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
                PopupMenuButton<String>(
                  icon:
                      const Icon(Icons.more_vert_rounded, color: Colors.brown),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        value: 'edit',
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProductScreen(
                                  productId: productId,
                                  initialName: name,
                                  initialPrice: price,
                                  initialAddress: address,
                                ),
                              ),
                            ).then((isUpdated) {
                              if (isUpdated == true) {
                                ourProductController.getOurProducts();
                              }
                            });
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: GestureDetector(
                          onTap: () {
                            ourProductController.deleteItem(productId);
                            Navigator.pop(context);
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete')
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
