import 'package:agribazar/views/buyer_views/search_product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class HomeController extends GetxController {
  Rx<User?> user = FirebaseAuth.instance.currentUser.obs;
  RxList<Map<String, dynamic>> featuredProducts = RxList([]);
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxInt cartItemCount = 0.obs;
  TextEditingController searchController = TextEditingController();
  RxList<Map<String, dynamic>> searchResult = RxList([]);
  RxBool isSearching = false.obs;
  final Logger logger = Logger();

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
      //logger.i('Crops fetched successfully: ${featuredProducts.length} items');
      //print(featuredProducts[0]['Description']);
    } catch (e) {
      errorMessage.value = 'Error fetching products: $e';
      logger.e('Error fetching featured products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Add item to Cart
  Future<void> addCartItem(String productId, String productName, int price,
      String pImage, String address) async {
    if (user.value == null) {
      Get.snackbar('Error', 'User not logged in.');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(user.value!.uid)
          .collection('item')
          .add({
        'productid': productId,
        'productname': productName,
        'productPrice': price,
        'productImage': pImage,
        'quantity': 1,
        'address': address,
      });

      _updateCartItemCount();
      Get.snackbar('Success', 'Item added to cart!');
    } catch (e) {
      logger.e('Error adding item to cart: $e');
      Get.snackbar('Error', 'Failed to add item to cart.');
    }
  }

  /// Update Cart Item Count from Firestore
  void _updateCartItemCount() {
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
    _updateCartItemCount();
  }
}
