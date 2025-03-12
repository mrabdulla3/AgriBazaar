import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class FarmerHomeController extends GetxController{
  
  RxMap<String, dynamic> userProfileData = <String, dynamic>{}.obs;
  RxBool isLoading = false.obs;
  var logger = Logger();

  
  Future<void> getUserInfo(User user) async {
    isLoading.value = true;
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        userProfileData.value = userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      logger.e('Error fetching user profile data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}