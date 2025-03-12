import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class CropFormController extends GetxController{

  final String cropType;

  CropFormController(this.cropType);
   
  @override
  void onInit() {
    super.onInit();
    cropCategoryController.text=cropType;
  }


  RxBool isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  var logger = Logger();
  Rx<File?> selectedFile = Rx<File?>(null);

  // Controllers for input fields
  final TextEditingController cropCategoryController = TextEditingController();
  final TextEditingController cropVarietyController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController keyFeatureController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController farmerAddressController = TextEditingController();

  void saveForm() async {
    if (formKey.currentState!.validate()) {
      
      isLoading.value = true; // Start loading when the form is being saved
     
      String cropCategory = cropCategoryController.text.trim();
      String cropVariety = cropVarietyController.text.trim();
      int cropQuantity = int.tryParse(quantityController.text.trim()) ?? 0;
      int cropPrice = int.tryParse(priceController.text.trim()) ?? 0;
      String feature = keyFeatureController.text.trim();
      String description = descriptionController.text.trim();
      String farmerAddress = farmerAddressController.text.trim();

      // Create a unique file name using UUID
      String uniqueFileName = const Uuid().v1();

      // Construct the path to store the image inside the category directory
      String filePath = '$cropCategory/$uniqueFileName';

      if (selectedFile.value != null) {
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child(filePath)
            .putFile(selectedFile.value!);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        User? currentUser = FirebaseAuth.instance.currentUser;
        String? userId = currentUser?.uid;

        Map<String, dynamic> cropForm = {
          "cropType": cropCategory,
          "Variety": cropVariety,
          "Quantity": cropQuantity,
          "Price": cropPrice,
          "Features": feature,
          "Description": description,
          "Crop Image": downloadUrl,
          "Address": farmerAddress,
          "userId": userId
        };

        await FirebaseFirestore.instance
            .collection('FormCropDetail')
            .add(cropForm);

        // Show success message
    
          Get.snackbar("Success!", "Form submitted successfully!");
        }
      else {
        Get.snackbar("Warning!", "Please select an image!");
      }

      // Clearing fields after form submission
      cropCategoryController.clear();
      cropVarietyController.clear();
      quantityController.clear();
      priceController.clear();
      keyFeatureController.clear();
      descriptionController.clear();
      farmerAddressController.clear();

     
        selectedFile.value = null;
        isLoading.value = false; // Stop loading after form submission
      
    } else {
      Get.snackbar("Warning!", "Please fill all required fields!");
    }
  }
}