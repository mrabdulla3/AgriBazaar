import 'package:agribazar/views/farmer_views/edit_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

class OurProducts extends StatefulWidget {
  const OurProducts({super.key});

  @override
  State<OurProducts> createState() => _OurProductsState();
}

class _OurProductsState extends State<OurProducts> {
  List<Map<String, dynamic>> productList = [];
  String errorMessage = '';
  var logger = Logger();
  bool isLoading = true;

  @override
  void initState() {
    getOurProducts();
  }

  Future<void> getOurProducts() async {
    try {
      QuerySnapshot items = await FirebaseFirestore.instance
          .collection('FormCropDetail')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      setState(() {
        productList = items.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      errorMessage = 'Error fetching products: $e';
      isLoading = false;
    }
  }

  Future<void> deleteItem(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('FormCropDetail')
          .doc(productId)
          .delete();
      setState(() {
        productList.removeWhere((product) => product['id'] == productId);
      });
    } catch (e) {
      logger.e("Error deleting product: $e");
    }
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
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.75, // Aspect ratio for the grid items
                  ),
                  itemCount: productList.length,
                  itemBuilder: (context, index) {
                    return buildProducts(
                      context,
                      productList[index]['Variety'],
                      productList[index]['Crop Image'],
                      productList[index]['Price'],
                      productList[index]['id'],
                      productList[index]['Address'],
                    );
                  },
                ),
            ],
          ),
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
                                getOurProducts();
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
                            deleteItem(productId);
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
