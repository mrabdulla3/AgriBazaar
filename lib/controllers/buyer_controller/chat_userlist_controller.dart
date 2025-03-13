import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ChatUserlistController extends GetxController {
  final String buyerId = FirebaseAuth.instance.currentUser!.uid;
  RxBool isSearching = false.obs;
  RxString searchQuery = ''.obs;
  TextEditingController searchController = TextEditingController();
}
