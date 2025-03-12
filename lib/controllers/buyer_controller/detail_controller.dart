import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class DetailController extends GetxController {
  DetailController({required this.user, required this.productId});
  User? user;
  String? productId;
  RxInt quantity = 1.obs;
  RxInt cartItemCount = 0.obs; // Add a cart item count
  RxString chatRoomId = "".obs;

  RxMap<String, dynamic>? productDetails;
  RxBool isLoading = true.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getProductDetail(); // Fetch product details when the page initializes
  }

  // Function to fetch product details from Firestore
  Future<void> getProductDetail() async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('FormCropDetail')
          .doc(productId) // Use the passed productId to get specific product
          .get();

      productDetails = RxMap<String, dynamic>.from(
          productSnapshot.data() as Map<String, dynamic>);
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Error fetching product details: $e';
      isLoading.value = false;
    }
  }
}
