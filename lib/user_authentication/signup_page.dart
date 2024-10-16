import 'dart:ffi';

import 'package:agribazar/Buyers/buyers_home.dart';
import 'package:agribazar/Farmer/farmer_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './terms_and_conditions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isLoading = false;
  String email = "",
      password = "",
      userType = "Farmer",
      name = "",
      address = "Street, House No. City",
      phone = "Phone",
      profileImageUrl = "";
  bool isChecked = false;
  bool _passwordVisible = false;

  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  registration() async {
    setState(() {
      isLoading = true;
    });
    if (password.isNotEmpty && email.isNotEmpty) {
      try {
        // Register user in Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        // Get the user ID
        String uid = userCredential.user!.uid;

        // Store user data (including userType) in Firestore
        await FirebaseFirestore.instance.collection("users").doc(uid).set({
          'name': name,
          'email': email,
          'userType': userType, // Store Farmer or Buyer
          'createdAt': Timestamp.now(),
          'address': address,
          'phone': phone,
          'profileImageUrl': profileImageUrl
        });

        // Display success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          "Registered Successfully",
          style: TextStyle(fontSize: 20.0),
        )));

        // Conditional Navigation based on userType
        if (userType == 'Farmer') {
          // Navigate to Farmer's Home page
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => SellerDashboard(
                        user: userCredential.user!,
                      )));
        } else if (userType == 'Buyer') {
          // Navigate to Buyer's Home page
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MarketHomePage(
                        user: userCredential.user!,
                      )));
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too Weak",
                style: TextStyle(fontSize: 18.0),
              )));
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 18.0),
              )));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Wrap in Form widget and assign key
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.1),
                // Logo at the top
                Image.asset(
                  'assets/agribazar.png',
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: screenWidth * 0.9,
                  child: TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Email Field
                SizedBox(
                  width: screenWidth * 0.9,
                  child: TextFormField(
                    controller: mailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.mail),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Password Field
                SizedBox(
                  width: screenWidth * 0.9,
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the password';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // User Type Drop-down
                SizedBox(
                  width: screenWidth * 0.9,
                  child: DropdownButtonFormField<String>(
                    value: userType,
                    decoration: const InputDecoration(
                      labelText: 'User Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: ['Farmer', 'Buyer']
                        .map((String type) => DropdownMenuItem<String>(
                            value: type, child: Text(type)))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        userType = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Terms & Conditions
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                        value: isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        }),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TermsAndConditionsPage()));
                      },
                      child: Text(
                        'Terms & Conditions',
                        style: GoogleFonts.abyssinicaSil(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sign Up Button
                SizedBox(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.06,
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate() &&
                                isChecked) {
                              setState(() {
                                name = nameController.text;
                                email = mailController.text;
                                password = passwordController.text;
                              });
                              registration();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Please accept the terms and conditions")));
                            }
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
