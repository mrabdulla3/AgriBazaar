import 'package:agribazar/views/farmer_views/our_products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class EditProductsController extends GetxController {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController addressController;
  RxBool isSaving = false.obs;

  Future<void> saveProductChanges(String productId) async {
    

    try {
      await FirebaseFirestore.instance
          .collection('FormCropDetail')
          .doc(productId)
          .update({
        'Variety': nameController.text,
        'Price': int.parse(priceController.text),
        'Address': addressController.text,
      });
      // Returning true to indicate success
      isSaving.value = true;
      
      Get.to(()=> OurProducts());
                       
    } catch (e) {
      Get.snackbar("Error!", "Error saving changes: $e");
    } finally {
      isSaving.value = false;
    }
  }
}
