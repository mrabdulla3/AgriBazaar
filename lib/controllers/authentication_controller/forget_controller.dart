import 'package:flutter/widgets.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';

class ForgetController extends GetxController {
  final TextEditingController mailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Reset Password Function
  resetPassword() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: mailController.text);
      Get.snackbar("Forget Pssword", "Password Reset Email Sent");
    } on FirebaseAuthException catch (e) {
      Get.snackbar("An error occurred", e.message!);
    }
  }
}
