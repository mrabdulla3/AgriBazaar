import 'package:agribazar/controllers/farmer_controller/edit_products_controller.dart';
import 'package:agribazar/views/farmer_views/our_products.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final String initialName;
  final int initialPrice;
  final String initialAddress;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.initialName,
    required this.initialPrice,
    required this.initialAddress,
  });

  @override
  EditProductScreenState createState() => EditProductScreenState();
}

class EditProductScreenState extends State<EditProductScreen> {
  
  final editPrdoctController = Get.put(EditProductsController());

  @override
  void initState() {
    super.initState();
    editPrdoctController.nameController = TextEditingController(text: widget.initialName);
    editPrdoctController.priceController =
        TextEditingController(text: widget.initialPrice.toString());
    editPrdoctController.addressController = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    editPrdoctController.nameController.dispose();
    editPrdoctController.priceController.dispose();
    editPrdoctController.addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product",
            style: GoogleFonts.abhayaLibre(
              textStyle: const TextStyle(
                  fontSize: 22, letterSpacing: .5, fontWeight: FontWeight.w600),
            )),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: editPrdoctController.nameController,
              decoration: const InputDecoration(
                  labelText: 'Product Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: editPrdoctController.priceController,
              decoration: const InputDecoration(
                  labelText: 'Price', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: editPrdoctController.addressController,
              decoration: const InputDecoration(
                  labelText: 'Address', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Obx(()=>
            editPrdoctController.isSaving.value
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFFDBE42), // Yellow color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed:(){
                       editPrdoctController.saveProductChanges(widget.productId);
                       
                      } ,
                      child: Text(
                        "Save Changes",
                        style: GoogleFonts.aclonica(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
            )
          ],
        ),
      ),
    );
  }
}
