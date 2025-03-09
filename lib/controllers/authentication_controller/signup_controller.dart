import 'package:get/get.dart';
import 'package:agribazar/views/buyer_views/buyers_home.dart';
import 'package:agribazar/views/farmer_views/farmer_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class SignupController extends GetxController {
  RxBool isLoading = false.obs;
  RxString email = "".obs;
  RxString password = "".obs;
  RxString userType = "Farmer".obs;
  RxString name = "".obs;
  RxString address = "Street, House No. City".obs;
  RxString phone = "Phone".obs;
  RxString profileImageUrl = "".obs;

  RxBool isChecked = false.obs;
  RxBool passwordVisible = false.obs;
  var logger = Logger();

  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  Future<void> registration() async {
    isLoading.value = true;

    if (password.value.isNotEmpty && email.value.isNotEmpty) {
      try {
        // Register user in Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: email.value, password: password.value);

        // Get the user ID
        String uid = userCredential.user!.uid;

        // Store user data (including userType) in Firestore
        await FirebaseFirestore.instance.collection("users").doc(uid).set({
          'name': name.value,
          'email': email.value,
          'userType': userType.value, // Store Farmer or Buyer
          'createdAt': Timestamp.now(),
          'address': address.value,
          'phone': phone.value,
          'profileImageUrl': profileImageUrl.value,
        });

        // Display success message
        Get.snackbar("Success", "${userType.value} Registered Successfully");

        // Conditional Navigation based on userType
        if (userType.value == 'Farmer') {
          // Navigate to Farmer's Home page
          Get.offAll(() => SellerDashboard(user: userCredential.user!));
        } else if (userType.value == 'Buyer') {
          // Navigate to Buyer's Home page
          Get.offAll(() => MarketHomePage(user: userCredential.user!));
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Get.snackbar("Warning", "Password Provided is too Weak");
        } else if (e.code == "email-already-in-use") {
          Get.snackbar("Warning", "Account Already exists");
        } else {
          Get.snackbar("", "Check your internet connection!");
        }
        isLoading.value = false;
      }
    }
  }
}
