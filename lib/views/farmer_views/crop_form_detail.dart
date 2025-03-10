import 'dart:io';
import 'package:agribazar/controllers/farmer_controller/crop_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CropDetailsPage extends StatelessWidget {
  final String cropType;

  CropDetailsPage({super.key, required this.cropType});

  @override
  Widget build(BuildContext context) {
    final cropformController = Get.put(CropFormController(cropType));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Include Crop Details",
          style: GoogleFonts.abhayaLibre(
            textStyle: const TextStyle(
              fontSize: 22,
              letterSpacing: .5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFFDBE42),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: cropformController.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    XFile? image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);

                    if (image != null) {
                      cropformController.selectedFile.value = File(image.path);
                      cropformController.logger.d("Image Selected!");
                    } else {
                      cropformController.logger.d("Image not Selected!");
                    }
                  },
                  child: Obx(
                    () {
                      final file = cropformController.selectedFile.value;
                      return Container(
                        height: 150,
                        decoration: const BoxDecoration(color: Colors.black12),
                        child: file != null
                            ? Center(
                                child: Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 40,
                                ),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                buildNonEditableTextField(
                    "Crop Type*", cropformController.cropCategoryController),
                buildTextField(
                    "Crop Name", cropformController.cropVarietyController),
                buildTextField(
                  "Quantity in kg*",
                  cropformController.quantityController,
                  inputType: TextInputType.number,
                ),
                buildTextField(
                  "Price per kg*",
                  cropformController.priceController,
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                buildTextField(
                  "Address: village, city pin.. *",
                  cropformController.farmerAddressController,
                  inputType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                buildTextField(
                  "Ad Title*",
                  cropformController.keyFeatureController,
                  hintText: "Mention key features (e.g., type, year, etc.)",
                  maxLength: 70,
                ),
                buildTextField(
                  "Description*",
                  cropformController.descriptionController,
                  hintText:
                      "Include condition, features, and any other important details",
                  maxLines: 6,
                  maxLength: 4096,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => cropformController.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFDBE42),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              cropformController.saveForm();
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
          enabled: false,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
