import 'dart:io';
import 'package:agribazar/controllers/farmer_controller/profile_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class ProfileFarmer extends StatelessWidget {
  final User user;
  ProfileFarmer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final profileController = Get.put(ProfileController(user));
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                height: screenHeight * 0.2,
                width: screenWidth,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.amberAccent],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Obx(
                          () => CircleAvatar(
                            radius: 40,
                            backgroundImage: profileController
                                        .selectedImage.value !=
                                    null
                                ? FileImage(profileController.selectedImage
                                    .value as File) // Show selected image
                                : profileController
                                        .profileImageUrl.value.isNotEmpty
                                    ? NetworkImage(
                                        profileController.profileImageUrl.value)
                                    : null, // Show uploaded image
                            child:
                                profileController.selectedImage.value == null &&
                                        profileController
                                            .profileImageUrl.value.isEmpty
                                    ? const Icon(Icons.camera_alt, size: 40)
                                    : null,
                          ),
                        ),

                        // Only show edit icon if in editing mode
                        Obx(() {
                          return profileController.isEditing.value
                              ? Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      profileController.pickImage();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 1.5,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(5),
                                      child: const Icon(
                                        Icons.edit,
                                        color:
                                            Color.fromARGB(255, 106, 105, 102),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }),
                        Obx(() {
                          return profileController.isUploading.value
                              ? const Positioned.fill(
                                  child: Center(
                                      child: CircularProgressIndicator()))
                              : const SizedBox.shrink();
                        }),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => Text(
                        profileController.userProfileData !=null
                            ? (profileController.userProfileData!['name'] ??
                                profileController.user?.displayName ??
                                'Unknown')
                            : 'Loading...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // User Information
              Obx(() {
                return profileController.userProfileData != null
                    ? Column(
                        children: [
                          buildProfileInfo(
                              Icons.person,
                              profileController.nameController,
                              profileController.userProfileData!['name'] ??'',
                              profileController),
                          buildProfileInfo(
                              Icons.location_on,
                              profileController.addressController,
                              profileController.userProfileData!['address']??'',
                              profileController),
                          buildProfileInfo(
                              Icons.phone,
                              profileController.phoneController,
                              profileController.userProfileData!['phone']??'',
                              profileController),
                          buildProfileInfo(
                            Icons.email,
                            TextEditingController(
                                text: profileController.user!.email),
                            'Email',
                            profileController,
                            readOnly: true,
                          ),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator());
              }),

              const SizedBox(height: 20),

              // Edit Profile Button
              Obx(
                () => ElevatedButton(
                  onPressed: () {
                    if (profileController.isEditing.value) {
                      profileController
                          .saveProfileData(); // Save data if editing
                    } else {
                      profileController.isEditing.value =
                          true; // Enable editing mode
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: Text(
                    profileController.isEditing.value ? 'Save' : 'Edit profile',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Widget buildProfileInfo(IconData icon, TextEditingController controller,
      String label, ProfileController profile_controller,
      {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber),
          const SizedBox(width: 20),
          Expanded(
              child: Obx(
            () => TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Colors.amber),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
              ),
              readOnly: !profile_controller.isEditing.value || readOnly,
            ),
          )),
        ],
      ),
    );
  }
}
