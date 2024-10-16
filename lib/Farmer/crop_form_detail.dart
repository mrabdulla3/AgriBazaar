import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CropDetailsPage extends StatefulWidget {
  final String cropType;

  const CropDetailsPage({required this.cropType, super.key});
  @override
  _CropDetailsPageState createState() => _CropDetailsPageState();
}

class _CropDetailsPageState extends State<CropDetailsPage> {
  File? selectedFile;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false; // Loading state

  // Controllers for input fields
  final TextEditingController _cropTypeController = TextEditingController();
  final TextEditingController _cropVarietyController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _keyFeatureController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _farmerAddressController =
      TextEditingController();
  String category = "Organic"; // Default crop category

  @override
  void initState() {
    super.initState();
    _cropTypeController.text =
        widget.cropType; // Set the cropType passed from the previous screen
  }

  void saveForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Start loading when the form is being saved
      });

      String cropCategory = _cropTypeController.text.trim();
      String cropVariety = _cropVarietyController.text.trim();
      String cropQuantity = _quantityController.text.trim();
      String cropPrice = _priceController.text.trim();
      String feature = _keyFeatureController.text.trim();
      String description = _descriptionController.text.trim();
      String farmerAddress = _descriptionController.text.trim();

      String categoryDirectory =
          _cropTypeController.text.trim(); // "Organic", "Hybrid", "Inorganic"

      // Create a unique file name using UUID
      String uniqueFileName = const Uuid().v1();

      // Construct the path to store the image inside the category directory
      String filePath = '$categoryDirectory/$uniqueFileName';

      if (selectedFile != null) {
        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child(filePath)
            .putFile(selectedFile!);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        Map<String, dynamic> cropForm = {
          "cropType": cropCategory,
          "Variety": cropVariety,
          "Quantity": cropQuantity,
          "Price": cropPrice,
          "Category": category,
          "Features": feature,
          "Description": description,
          "Crop Image": downloadUrl,
          "Address": farmerAddress
        };

        await FirebaseFirestore.instance
            .collection('FormCropDetail')
            .add(cropForm);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image.')),
        );
      }

      // Clearing fields after form submission
      _cropTypeController.clear();
      _cropVarietyController.clear();
      _quantityController.clear();
      _priceController.clear();
      _keyFeatureController.clear();
      _descriptionController.clear();
      _farmerAddressController.clear();

      setState(() {
        selectedFile = null;
        isLoading = false; // Stop loading after form submission
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Include Crop Details"),
        backgroundColor: const Color(0xFFFDBE42),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    XFile? image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);

                    if (image != null) {
                      setState(() {
                        selectedFile = File(image.path);
                        print("Image Selected!");
                      });
                    } else {
                      print("Image not Selected!");
                    }
                  },
                  child: Container(
                    height: 150,
                    decoration: const BoxDecoration(color: Colors.black12),
                    child: selectedFile != null
                        ? Center(
                            child: Image.file(
                            selectedFile!,
                            fit: BoxFit.cover,
                          ))
                        : const Center(
                            child: Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                          )),
                  ),
                ),
                const SizedBox(height: 16),
                buildNonEditableTextField("Crop Type*", _cropTypeController),
                buildTextField("Crop Variety", _cropVarietyController),
                buildTextField("Quantity *", _quantityController,
                    inputType: TextInputType.text),
                buildTextField("Price *", _priceController,
                    inputType: TextInputType.text),
                const SizedBox(height: 16),
                buildTextField(
                    "Address: village, city pin.. *", _farmerAddressController,
                    inputType: TextInputType.text),
                const SizedBox(height: 16),
                const Text("Category",
                    style: TextStyle(fontSize: 16, color: Colors.white70)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildCategoryButton("Organic", category),
                    buildCategoryButton("Hybrid", category),
                    buildCategoryButton("Inorganic", category),
                  ],
                ),
                const SizedBox(height: 16),
                buildTextField("Ad Title*", _keyFeatureController,
                    hintText: "Mention key features (e.g., type, year, etc.)",
                    maxLength: 70),
                buildTextField("Description*", _descriptionController,
                    hintText:
                        "Include condition, features, and any other important details",
                    maxLines: 6,
                    maxLength: 4096),
                const SizedBox(height: 16),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFDBE42), // Yellow color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            saveForm();
                          },
                          child: Text(
                            'Save',
                            style: GoogleFonts.aclonica(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text,
      String? hintText,
      int? maxLength,
      int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hintText ?? "Enter $label",
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // For Crop Type field (not editable)
  Widget buildNonEditableTextField(
      String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: false, // This makes the field non-editable
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Helper method to build category buttons
  Widget buildCategoryButton(String buttonText, String currentCategory) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            category = buttonText;
          });
        },
        child: Text(buttonText),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              category == buttonText ? const Color(0xFFFDBE42) : Colors.white,
          foregroundColor: category == buttonText ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
