import 'package:get/get.dart';
import 'package:agribazar/views/buyer_views/buyers_home.dart';
import 'package:agribazar/views/farmer_views/farmer_home.dart';
import 'package:agribazar/views/authentication_views/authScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashController extends GetxController {
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  // Function to navigate based on authentication state
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 4));

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _getUserTypeAndNavigate(user.uid);
      } else {
        Get.offAll(() => const AuthScreen());
      }
    });
  }

  // Function to fetch user type and navigate accordingly
  Future<void> _getUserTypeAndNavigate(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        String userType = userDoc['userType'];
        if (userType == 'Farmer') {
          Get.offAll(
              () => SellerDashboard(user: FirebaseAuth.instance.currentUser));
        } else if (userType == 'Buyer') {
          Get.offAll(
              () => MarketHomePage(user: FirebaseAuth.instance.currentUser));
        } else {
          Get.snackbar("Error", "User data not found. Please register.");
          Get.offAll(() => const AuthScreen());
        }
      }
    } catch (e) {
      Get.offAll(() => const AuthScreen());
    }
  }
}
