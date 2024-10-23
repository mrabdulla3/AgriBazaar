import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileFarmer extends StatefulWidget {
  final User user;
  const ProfileFarmer({super.key, required this.user});

  @override
  ProfileFarmerState createState() => ProfileFarmerState();
}

class ProfileFarmerState extends State<ProfileFarmer> {
  Map<String, dynamic>? userProfileData;
  bool isEditing = false;
  bool isUploading = false; // Flag to show loading indicator
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  String? profileImageUrl;
  String? newProfileImageUrl; // Temporary image URL for editing
  File? selectedImage; // To store selected image locally
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getUserProfileData();
  }

  Future<void> _getUserProfileData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userProfileData = userDoc.data() as Map<String, dynamic>;

          nameController.text = userProfileData!['name'] ?? "";
          addressController.text = userProfileData!['address'] ?? '';
          phoneController.text = userProfileData!['phone'] ?? '';
          profileImageUrl = userProfileData!['profileImageUrl'];
        });
      }
    } catch (e) {
      print('Error fetching user profile data: $e');
    }
  }

  Future<void> _saveProfileData() async {
    try {
      // Only upload the image if it has been edited (i.e., selectedImage is not null)
      if (selectedImage != null) {
        setState(() {
          isUploading = true;
        });
        String fileName = '${widget.user.uid}/profile_image.png';
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child('profilePictures')
            .child(fileName)
            .putFile(selectedImage!);

        TaskSnapshot snapshot = await uploadTask;
        newProfileImageUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          profileImageUrl = newProfileImageUrl;
          isUploading = false;
        });
      }

      // Save profile data (including the new profile image if it was updated)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .update({
        'name': nameController.text,
        'address': addressController.text,
        'phone': phoneController.text,
        'profileImageUrl': profileImageUrl,
      });

      setState(() {
        isEditing = false;
      });
    } catch (e) {
      print('Error saving profile data: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImage = File(image.path); // Store selected image locally
        });
      }
    } catch (e) {
      print('Error selecting profile image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

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
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: selectedImage != null
                            ? FileImage(selectedImage!) // Show selected image
                            : profileImageUrl != null
                                ? NetworkImage(profileImageUrl!)
                                : null, // Show uploaded image
                        child: selectedImage == null && profileImageUrl == null
                            ? const Icon(Icons.camera_alt, size: 40)
                            : null,
                      ),
                      // Only show edit icon if in editing mode
                      if (isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              _pickImage(); // Allow picking image when editing
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
                                color: Color.fromARGB(255, 106, 105, 102),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      if (isUploading)
                        const Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          top: 0,
                          child: Center(
                            child:
                                CircularProgressIndicator(), // Show loading indicator while uploading
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userProfileData != null
                        ? userProfileData!['name'] ??
                            widget.user.displayName ??
                            'Unknown'
                        : 'Loading...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // User Information
            userProfileData != null
                ? Column(
                    children: [
                      buildProfileInfo(Icons.person, nameController,
                          userProfileData!['name']),
                      buildProfileInfo(Icons.location_on, addressController,
                          userProfileData!['address']),
                      buildProfileInfo(Icons.phone, phoneController,
                          userProfileData!['phone']),
                      buildProfileInfo(
                        Icons.email,
                        TextEditingController(text: widget.user.email),
                        'Email',
                        readOnly: true,
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),

            const SizedBox(height: 20),

            // Edit Profile Button
            ElevatedButton(
              onPressed: () {
                if (isEditing) {
                  _saveProfileData(); // Save data if editing
                } else {
                  setState(() {
                    isEditing = true; // Enable editing mode
                  });
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
                isEditing ? 'Save' : 'Edit profile',
                style: const TextStyle(fontSize: 16),
              ),
            ),
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
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Colors.amber),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.amber),
                ),
              ),
              readOnly: !isEditing || readOnly,
            ),
          ),
        ],
      ),
    );
  }
}
