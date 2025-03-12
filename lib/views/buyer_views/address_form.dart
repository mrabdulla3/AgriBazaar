import 'package:agribazar/controllers/buyer_controller/address_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';

class EditAddressPage extends StatefulWidget {
  final User user;

  const EditAddressPage({required this.user, super.key});

  @override
  EditAddressPageState createState() => EditAddressPageState();
}

class EditAddressPageState extends State<EditAddressPage> {
  late AddressController addressController;
  @override
  void initState() {
    super.initState();
    addressController = Get.put(AddressController(user: widget.user));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: addressController.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: addressController.addressController,
                decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter your: Village, City, Pin Code, State',
                    hintStyle: TextStyle(color: Colors.grey)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addressController.saveAddress,
                child: const Text('Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
