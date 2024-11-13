import 'package:agribazar/Buyers/cart.dart';
import 'package:agribazar/Buyers/category.dart';
import 'package:agribazar/Buyers/chat_userlist.dart';
import 'package:agribazar/Buyers/detailed_page.dart';
import 'package:agribazar/Buyers/notification.dart';
import 'package:agribazar/Buyers/pricing.dart';
import 'package:agribazar/Buyers/profile.dart';
import 'package:agribazar/Buyers/search_product.dart';
import 'package:agribazar/Buyers/sidebar.dart';
import 'package:agribazar/user_authentication/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';

class MarketHomePage extends StatefulWidget {
  final User? user;

  const MarketHomePage({this.user, super.key});

  @override
  State<MarketHomePage> createState() => _MarketHomePageState();
}

class _MarketHomePageState extends State<MarketHomePage> {
  List<Map<String, dynamic>> featuredProducts = [];
  bool isLoading = true;
  String errorMessage = '';
  int cartItemCount = 0; // Add a cart item count
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResult = [];
  bool isSearching = false;
  var logger = Logger();

  Future<void> _getCrops() async {
    try {
      QuerySnapshot cropSnapshot =
          await FirebaseFirestore.instance.collection('FormCropDetail').get();

      setState(() {
        featuredProducts = cropSnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
      //print(featuredProducts);
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching products: $e';
        isLoading = false;
      });
      logger.e('Error fetching featured products: $e');
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added to cart!')),
        );
      }
    } catch (e) {
      logger.e('Error adding item to cart: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getCrops();
  }

  void searchQuery(String val) {
    if (featuredProducts.isNotEmpty && val.isNotEmpty) {
      setState(() {
        searchResult = featuredProducts.where((product) {
          final cropName = product['Variety'].toString().toLowerCase();
          return cropName.contains(val.toLowerCase());
        }).toList();
      });

      if (searchResult.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SearchProduct(user: widget.user, searchedList: searchResult),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No results found for "$val"')),
        );
      }
    }
    searchController.clear();
  }

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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatMessageBuyer(),
                  ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Notifications(),
                  ));
            },
          ),
        ],
      ),
      drawer: Sidebar(
        user: widget.user!,
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
                  controller: searchController,
                  onSubmitted: (value) {
                    searchQuery(value);
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
                        searchQuery(searchController.text);
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
                  itemCount: featuredProducts.length,
                  itemBuilder: (context, index) {
                    // print(featuredProducts[index]['Variety']);
                    return buildFeaturedProduct(
                      featuredProducts[index]['Variety'],
                      featuredProducts[index]['Crop Image'],
                      featuredProducts[index]['Price'],
                      featuredProducts[index]['id'],
                      featuredProducts[index]['Address'],
                    );
                  },
                ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MarketHomePage(),
                  ),
                );
              },
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cart(
                      user: widget.user!,
                    ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Pricing(),
                  ),
                );
              },
            ),
            label: 'Pricing',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                if (widget.user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile(
                        user: widget.user!, // Pass the user if not null
                      ),
                    ),
                  );
                } else {
                  // Navigate to the signup page if user is null
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SignUpPage(), // Your signup page widget
                    ),
                  );
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
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      Categorys(user: widget.user!, cropType: title),
                ));
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
      String productId, String address) {
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
                      addCartItem(productId, name, price, imageUrl, address);
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
