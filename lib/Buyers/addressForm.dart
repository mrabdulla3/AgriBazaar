import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditAddressPage extends StatefulWidget {
  final User user;

  const EditAddressPage({required this.user, super.key});

  @override
  EditAddressPageState createState() => EditAddressPageState();
}

class EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserAddress(); // Load the current address from Firestore
  }

  Future<void> _loadUserAddress() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _addressController.text = userDoc.get('address') ?? '';
      });
    }
  }

  Future<void> _saveAddress() async {}

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
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
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _addressController,
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
                onPressed: _saveAddress,
                child: const Text('Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
