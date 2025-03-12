import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ChatMessageController extends GetxController{
  String? farmerId;
  
  TextEditingController searchController = TextEditingController();
  RxBool isSearching = false.obs;
  RxString searchQuery = "".obs;

   @override
  void onInit() {
    super.onInit();
    farmerId = FirebaseAuth.instance.currentUser?.uid;
  }
}