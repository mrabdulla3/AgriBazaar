import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  ProfileController({required this.user});
  User? user;
  RxMap<String, dynamic>? userProfileData = <String, dynamic>{}.obs;
  RxBool isEditing = false.obs;
  RxBool isUploading = false.obs;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  RxString errorMessage = ''.obs;

  RxString profileImageUrl = "".obs;
  RxString? newProfileImageUrl = "".obs; // Temporary image URL for editing
  Rx<File?> selectedImage = Rx<File?>(null); // To store selected image locally
  final ImagePicker _picker = ImagePicker();
  @override
  void onInit() {
    super.onInit();
    if (user != null) {
      getUserProfileData();
    }
  }

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
      errorMessage.value = 'Error fetching profile details: $e';
    }
  }

  Future<void> saveProfileData() async {
    isUploading.value = true;

    try {
      // Only upload the image if it has been edited (i.e., selectedImage is not null)
      if (selectedImage.value != null) {
        String fileName = '${user!.uid}/profile_image.png';
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child('profilePictures')
            .child(fileName)
            .putFile(selectedImage.value!);

        TaskSnapshot snapshot = await uploadTask;
        newProfileImageUrl!.value = await snapshot.ref.getDownloadURL();
        profileImageUrl.value =
            newProfileImageUrl!.value; // Update profile image URL
      }
      // Save profile data (including the new profile image if it was updated)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'name': nameController.text,
        'address': addressController.text,
        'phone': phoneController.text,
        'profileImageUrl': profileImageUrl,
      });

      isEditing.value = false;
    } catch (e) {
      errorMessage.value = 'Error saving profile data: $e';
    } finally {
      isUploading.value = false; // Reset uploading flag
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = File(image.path); // Store selected image locally
      }
    } catch (e) {
      errorMessage.value = 'Error selecting profile image: $e';
    }
  }
}
