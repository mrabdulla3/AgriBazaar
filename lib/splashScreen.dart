import 'package:agribazar/Buyers/buyers_home.dart';
import 'package:agribazar/Farmer/farmer_home.dart';
import 'package:agribazar/user_authentication/authScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  bool userExist = false;

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
      // User is logged in, set userExist to true and navigate
      setState(() {
        userExist = true;
      });
      _getUserTypeAndNavigate(user.uid);
    } else {
      // User is not logged in, set userExist to false and show AuthScreen
      setState(() {
        userExist = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SellerDashboard(user: FirebaseAuth.instance.currentUser!),
            ),
          );
        } else if (userType == 'Buyer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MarketHomePage(user: FirebaseAuth.instance.currentUser!),
            ),
          );
        } else {
          // Show error message if user data not found
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("User data not found. Please register."),
          ));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AuthScreen(),
            ),
          );
        }
      }
    } catch (e) {
      // Handle errors and navigate to AuthScreen in case of failure
      print('Error fetching user data: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthScreen(),
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
          // Overlay for text visibility
          Positioned(
            top: screenHeight * 0.5,
            child: Container(
                height: screenHeight * 0.5,
                width: screenWidth,
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(70),
                      topRight: Radius.circular(70),
                    )),
                child: userExist
                    ? Column(
                        // Show container content if user does not exist
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
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .green, // Sign In button color
                                        minimumSize:
                                            Size(screenWidth * 0.3, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AuthScreen(),
                                          ),
                                        );
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
                                        backgroundColor: Colors
                                            .black, // Sign Up button color
                                        minimumSize:
                                            Size(screenWidth * 0.3, 50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AuthScreen(),
                                          ),
                                        );
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
                                const SizedBox(height: 70),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const MarketHomePage(
                                                      user: null),
                                            ));
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
                      )
                    : const Center(
                        // Show loading indicator if user exists
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: LoadingIndicator(
                            indicatorType: Indicator.lineSpinFadeLoader,
                            colors: [Colors.white],
                            strokeWidth: 2,
                          ),
                        ),
                      )),
          ),
        ],
      ),
    );
  }
}
