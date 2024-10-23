import 'package:agribazar/Buyers/cart.dart';
import 'package:agribazar/Buyers/chat_message.dart';
import 'package:agribazar/Buyers/detailed_page.dart';
import 'package:agribazar/Buyers/notification.dart';
import 'package:agribazar/Buyers/pricing.dart';
import 'package:agribazar/Buyers/profile.dart';
import 'package:agribazar/Buyers/sidebar.dart';
import 'package:agribazar/user_authentication/signup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      print('Error fetching featured products: $e');
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
    _getCrops();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriBazaar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.mail),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatMessage(),
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
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                      color: const Color.fromARGB(255, 113, 109, 109),
                      width: 2),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.black),
                  ),
                ),
              ),
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
              const Text(
                "Category",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildCategoryItem("Vegetables", 'assets/tomato.png'),
                  buildCategoryItem("Fruits", 'assets/fruits.jpg'),
                  buildCategoryItem("Rice", 'assets/rice.jpg'),
                  buildCategoryItem("Wheat", 'assets/Wheat.jpg'),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),

              // Featured Products section with GridView
              const Text(
                "Featured Products",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            // Handle navigation to category page
            //   Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) =>Category(),
            //       ));
            //
          },
          child: CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(imagePath),
          ),
        ),
        const SizedBox(height: 5),
        Text(title),
      ],
    );
  }

  // Function to build each featured product
  Widget buildFeaturedProduct(String name, String imageUrl, int price,
      String productId, String address) {
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
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.error,
                    size: 80,
                    color: Colors.red,
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
