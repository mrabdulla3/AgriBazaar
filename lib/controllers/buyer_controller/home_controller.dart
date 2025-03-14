import 'package:agribazar/views/buyer_views/search_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class HomeController extends GetxController {
  RxInt cartItemCount = 0.obs;
  Rx<User?> user = FirebaseAuth.instance.currentUser.obs;
  RxList<Map<String, dynamic>> featuredProducts = RxList([]);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  TextEditingController searchController = TextEditingController();
  RxList<Map<String, dynamic>> searchResult = RxList([]);
  RxBool isSearching = false.obs;
  RxInt currentIndex = 0.obs; // For dot indicator
  final Logger logger = Logger();

  List<String> bannerImages = [
    'assets/banner1.jpg',
    'assets/banner2.jpg',
    'assets/banner3.jpg',
    'assets/banner4.jpg',
  ];

  /// Update Cart Item Count from Firestore
  void updateCartItemCount() {
    if (user.value == null) return;

    FirebaseFirestore.instance
        .collection('carts')
        .doc(user.value!.uid)
        .collection('item')
        .snapshots()
        .listen((snapshot) {
      cartItemCount.value = snapshot.docs.length;
    });
  }

  /// Fetch Crops Data from Firestore
  Future<void> _getCrops() async {
    isLoading.value = true;
    try {
      // logger.i('Fetching crops data...');
      QuerySnapshot cropSnapshot =
          await FirebaseFirestore.instance.collection('FormCropDetail').get();

      featuredProducts.value = cropSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      //print(featuredProducts[0]['Description']);
    } catch (e) {
      errorMessage.value = 'Error fetching products: $e';
      logger.e('Error fetching featured products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search Products by Name
  void searchQuery(String val) {
    if (val.trim().isEmpty) {
      Get.snackbar("Warning", "Please enter a search query.");
      return;
    }

    searchResult.value = featuredProducts.where((product) {
      final cropName = product['Variety']?.toString().toLowerCase() ?? '';
      return cropName.contains(val.toLowerCase());
    }).toList();

    if (searchResult.isNotEmpty) {
      Get.to(() => SearchProduct(user: user.value, searchedList: searchResult));
    } else {
      Get.snackbar("Warning", 'No results found for "$val"');
    }

    searchController.clear();
  }

  @override
  void onInit() {
    super.onInit();
    _getCrops();
    updateCartItemCount();
  }
}
