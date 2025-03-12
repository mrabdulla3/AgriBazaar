import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class CategoryController extends GetxController {
  CategoryController({required this.user, required this.cropType});
  String? cropType;
  User? user;
  RxList<Map<String, dynamic>> productsList = RxList([]);
  RxString errorMessage = ''.obs;
  RxBool isLoading = true.obs;
  RxInt cartItemCount = 0.obs; // Add a cart item count
  var logger = Logger();

  @override
  void onInit() {
    super.onInit();
    _getCrops(cropType!);
  }

  Future<void> _getCrops(String category) async {
    try {
      QuerySnapshot cropSnapshot = await FirebaseFirestore.instance
          .collection('FormCropDetail')
          .where('cropType', isEqualTo: category)
          .get();
      productsList.value = cropSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      isLoading.value = false;
      //print(productsList);
    } catch (e) {
      errorMessage.value = 'Error fetching crops for $category: $e';
      isLoading.value = false;
      logger.e('Error fetching crops: $e');
    }
  }
}
