import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class AddressController extends GetxController {
  AddressController({required this.user});
  User? user;
  final formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserAddress(); // Load the current address from Firestore
  }

  Future<void> loadUserAddress() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (userDoc.exists) {
      addressController.text = userDoc.get('address') ?? '';
    }
  }

  Future<void> saveAddress() async {}

  @override
  void onClose() {
    super.onClose();
    addressController.dispose();
  }
}
