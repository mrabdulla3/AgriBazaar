import 'package:agribazar/Buyers/buyers_home.dart';
import 'package:agribazar/Farmer/farmer_home.dart';
import 'package:agribazar/user_authentication/authScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  // Function to navigate based on authentication state
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 4));

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, fetch user type from Firestore
      _getUserTypeAndNavigate(user.uid);
    } else {
      // User is not logged in, navigate to AuthScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthScreen(),
        ),
      );
    }
  }

  // Function to fetch user type and navigate accordingly
  Future<void> _getUserTypeAndNavigate(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        String userType = userDoc['userType'];

        if (userType == 'Farmer') {
          // Navigate to Farmer Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SellerDashboard(user: FirebaseAuth.instance.currentUser!),
            ),
          );
        } else if (userType == 'Buyer') {
          // Navigate to Buyer Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MarketHomePage(user: FirebaseAuth.instance.currentUser!),
            ),
          );
        } else {
          // User data not found, show a message and navigate to AuthScreen
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("User data not found. Please register."),
          ));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AuthScreen(),
            ),
          );
        }
      }
    } catch (e) {
      // Handle errors
      print('Error fetching user data: $e');

      // If there's an error, navigate to the AuthScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            height: screenHeight,
            width: screenWidth,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/splashImg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay to make text visible on image
          Positioned(
            top: screenHeight * 0.5,
            child: Container(
              height: screenHeight * 0.5,
              width: screenWidth,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(70),
                      topRight: Radius.circular(70))),
              // Adjust opacity for visibility
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30.0, horizontal: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // App logo and title
                        Column(
                          children: [
                            Text(
                              'AgriBazaar',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'The AgriBazaar app connecting\nfarmers with buyers for secure agreements.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // Buttons for Sign In and Sign Up
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green, // Sign In button color
                                minimumSize: Size(screenWidth * 0.3, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AuthScreen(),
                                    ));
                              },
                              child: Text(
                                'Sign in',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.black, // Sign Up button color
                                minimumSize: Size(screenWidth * 0.3, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AuthScreen(),
                                    ));
                              },
                              child: Text(
                                'SignUp',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Skip button with icon
                        const SizedBox(
                          height: 70,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Handle Skip button press
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MarketHomePage(user: null)));
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'Skip',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
