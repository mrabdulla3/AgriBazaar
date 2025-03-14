import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class ProfileController extends GetxController{
  

  ProfileController({required this.user});
  User ?user;
  @override
  void onInit() {
    super.onInit();
    if (user != null) {
      getUserProfileData();
    }
  }
  final ImagePicker _picker = ImagePicker();
   RxMap<String, dynamic>? userProfileData = <String, dynamic>{}.obs;

  RxBool isEditing = false.obs;
  RxBool isUploading = false.obs;
  Rx<String> profileImageUrl="".obs;
  Rx<String> newProfileImageUrl="".obs; // Temporary image URL for editing
  Rx<File?> selectedImage = Rx<File?>(null);
 // To store selected image locally


  TextEditingController nameController=TextEditingController();
  TextEditingController phoneController=TextEditingController();
  TextEditingController addressController=TextEditingController();
  var logger = Logger();
  
  Future<void> getUserProfileData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
       
          userProfileData!.value = userDoc.data() as Map<String, dynamic>;

          nameController.text = userProfileData!['name'] ?? "";
          addressController.text = userProfileData!['address'] ?? '';
          phoneController.text = userProfileData!['phone'] ?? '';
          profileImageUrl.value = userProfileData!['profileImageUrl'];
      
      }
    } catch (e) {
     logger.e('Error fetching user profile data: $e');
    }
  }


   Future<void> saveProfileData() async {
    try {
      // Only upload the image if it has been edited (i.e., selectedImage is not null)
      if (selectedImage.value != null) {
      
          isUploading.value = true;
     
        String fileName = '${user!.uid}/profile_image.png';
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child('profilePictures')
            .child(fileName)
            .putFile(selectedImage as File);

        TaskSnapshot snapshot = await uploadTask;
        newProfileImageUrl.value = (await snapshot.ref.getDownloadURL());
     
          profileImageUrl.value = newProfileImageUrl.value;
          isUploading.value = false;
      
      }

      // Save profile data (including the new profile image if it was updated)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'name': nameController.text,
        'address': addressController.text,
        'phone': phoneController.text,
        'profileImageUrl': profileImageUrl.value,
      });
      isEditing.value = false;
      getUserProfileData();
    } catch (e) {
      logger.e('Error saving profile data: $e');
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
          selectedImage.value = File(image.path); // Store selected image locally
      }
    } catch (e) {
      logger.e('Error selecting profile image: $e');
    }
  }
  
}