import 'package:get/get.dart';
import 'package:agribazar/views/buyer_views/buyers_home.dart';
import 'package:agribazar/views/farmer_views/farmer_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class SigninController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = "", password = "";
  RxBool rememberMe = false.obs;
  RxBool passwordVisible = false.obs;
  RxBool isLoading = false.obs;
  var logger = Logger();

  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final formkey = GlobalKey<FormState>();

  userLogin() async {
    isLoading.value = true;
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        String userType = userDoc['userType'];
        if (userType == 'Farmer') {
          Get.off(SellerDashboard(user: userCredential.user!));
        } else if (userType == 'Buyer') {
          Get.off(MarketHomePage(user: userCredential.user!));
        } else {
          Get.snackbar("Error", "User data not found. Please register.");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar("Warning", "No User Found for that Email");
      } else if (e.code == 'wrong-password') {
        Get.snackbar("Warning", "Wrong Password Provided by User");
      } else {
        Get.snackbar("Warning", "Check your internet connection!");
      }
      isLoading.value = false;
    }
  }

  Future<User?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        return userCredential.user;
      } on FirebaseAuthException catch (e) {
        logger.e(e.message);
      }
    }
    return null;
  }
}
