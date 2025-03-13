import 'package:agribazar/controllers/buyer_controller/home_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class CartController extends GetxController {
  final HomeController homeController = Get.put(HomeController());
  RxDouble total = 0.0.obs;
  RxDouble subtotal = 0.0.obs;
  Rx<User?> user = FirebaseAuth.instance.currentUser.obs;
  RxList<Map<String, dynamic>> cartProducts = RxList([]);
  RxBool isPickup = false.obs;
  RxDouble deliveryCharge = 30.00.obs;
  var logger = Logger();

  /// Add item to Cart
  Future<void> addCartItem(String productId, String productName, int price,
      String pImage, String address) async {
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
      calculateSubtotal();
      homeController.updateCartItemCount();
      Get.snackbar('Success', 'Item added to cart!');
    } catch (e) {
      logger.e('Error adding item to cart: $e');
      Get.snackbar('Error', 'Failed to add item to cart.');
    }
  }

  void calculateSubtotal() {
    subtotal.value = cartProducts.fold(
        0.0, (sum, p) => sum + (p['productPrice'] * p['quantity']));
    total.value = subtotal.value + (isPickup.value ? 0 : deliveryCharge.value);
  }

  void updateQuantity(int index, int newQuantity) {
    cartProducts[index]['quantity'] = newQuantity;
    cartProducts.refresh(); // This ensures UI updates
    calculateSubtotal();
  }

  Future<void> getCartItem() async {
    try {
      QuerySnapshot cartItem = await FirebaseFirestore.instance
          .collection('carts')
          .doc(user.value!.uid)
          .collection('item')
          .get();

      cartProducts.value = cartItem.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        double productPrice = (data['productPrice'] is int)
            ? (data['productPrice'] as int).toDouble()
            : (data['productPrice'] as double? ?? 0.0);

        return {
          'documentId': doc.id,
          'productImage': data['productImage'] ?? 'assets/splashImg.jpg',
          'address': data['address'] ?? '149, Sunset Ave, Los Angeles, CA',
          'productname': data['productname'] ?? 'Unknown Product',
          'productPrice': productPrice,
          'quantity': data['quantity'] is int ? data['quantity'] : 1,
        };
      }).toList();
      //print(cartProducts);
    } catch (e) {
      logger.e("Error fetching cart items: $e");
    }
  }

  void removeCartItem(int index) async {
    try {
      String docId = cartProducts[index]['documentId'];
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(user.value!.uid)
          .collection('item')
          .doc(docId)
          .delete();

      cartProducts.removeAt(index);
      calculateSubtotal();
      Get.snackbar('Success', 'Cart item removed');
    } catch (e) {
      //print("Error deleting cart item: $e");
      Get.snackbar('Warning', 'Failed to remove item');
    }
  }
}
