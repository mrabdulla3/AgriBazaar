import 'dart:io';
import 'package:agribazar/controllers/buyer_controller/profile_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/instance_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatefulWidget {
  final User? user;
  const Profile({super.key, required this.user});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  late ProfileController profileController;
  @override
  void initState() {
    super.initState();
    profileController = Get.put(ProfileController(user: widget.user));
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    print(profileController.userProfileData!["name"]);
    print(widget.user!.displayName);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Get.back();
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
                      Obx(() => CircleAvatar(
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
                            child: profileController.selectedImage.value ==
                                        null &&
                                    profileController.profileImageUrl.isEmpty
                                ? const Icon(Icons.camera_alt, size: 40)
                                : null,
                          )),
                      // Only show edit icon if in editing mode
                      Obx(() {
                        return profileController.isEditing.value
                            ? Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: profileController.pickImage,
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
                                      color: Color.fromARGB(255, 106, 105, 102),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      }),
                      Obx(
                        () {
                          return profileController.isUploading.value
                              ? const Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  top: 0,
                                  child: Center(
                                    child:
                                        CircularProgressIndicator(), // Show loading indicator while uploading
                                  ),
                                )
                              : const SizedBox.shrink();
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    print(widget.user!.displayName);
                    print(profileController.userProfileData!['name']);
                    return Text(
                      profileController.userProfileData != null
                          ? profileController.userProfileData!['name'] ??
                              widget.user!.displayName ??
                              'Unknown'
                          : 'Loading...',
                      style: GoogleFonts.abhayaLibre(
                        textStyle: const TextStyle(
                            fontSize: 20,
                            letterSpacing: .5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    );
                  })
                ],
              ),
            ),
            const SizedBox(height: 20),
            // User Information
            widget.user != null
                ? Column(
                    children: [
                      buildProfileInfo(Icons.person,
                          profileController.nameController, 'Name'),
                      buildProfileInfo(Icons.location_on,
                          profileController.addressController, 'Address'),
                      buildProfileInfo(Icons.phone,
                          profileController.phoneController, 'Phone'),
                      buildProfileInfo(
                        Icons.email,
                        TextEditingController(text: widget.user!.email),
                        'Email',
                        readOnly: true,
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),

            const SizedBox(height: 20),
            Obx(() {
              return ElevatedButton(
                onPressed: () {
                  if (profileController.isEditing.value) {
                    print(1);
                    profileController.saveProfileData(); // Save data if editing
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  profileController.isEditing.value ? 'Save' : 'Edit profile',
                  style: GoogleFonts.abhayaLibre(
                    textStyle: const TextStyle(
                        fontSize: 18,
                        letterSpacing: .5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              );
            })
          ],
        ),
      ),
    );
  }

  Widget buildProfileInfo(
      IconData icon, TextEditingController controller, String label,
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
              readOnly: !profileController.isEditing.value || readOnly,
            ),
          )),
        ],
      ),
    );
  }
}
