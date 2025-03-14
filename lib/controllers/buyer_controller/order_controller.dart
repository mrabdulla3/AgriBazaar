import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  RxMap<String, dynamic> orderSuccess = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> myOrders = <Map<String, dynamic>>[].obs;
  RxBool isFetching = false.obs;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> placeOrders(List<Map<String, dynamic>> cartItems) async {
    if (cartItems.isEmpty) return;

    final FirebaseAuth auth = FirebaseAuth.instance;
    final String? buyerId = auth.currentUser?.uid;

    try {
      // Group items by farmerId
      Map<String, List<Map<String, dynamic>>> ordersByFarmer = {};

      for (var item in cartItems) {
        String? farmerId = item["farmerId"]; // Ensure farmerId is non-null
        //print(farmerId);

        if (farmerId == null) {
          print("Error: Missing farmerId in cart item: $item");
          continue; // Skip this item if farmerId is null
        }

        if (!ordersByFarmer.containsKey(farmerId)) {
          ordersByFarmer[farmerId] = [];
        }
        ordersByFarmer[farmerId]?.add(item);
      }

      // Store separate orders for each farmer
      for (var farmerId in ordersByFarmer.keys) {
        DocumentReference orderRef = firestore.collection("orders").doc();

        Map<String, dynamic> orderData = {
          "orderId": orderRef.id,
          "buyerId": buyerId,
          "farmerId": farmerId,
          "status": "Pending",
          "items": ordersByFarmer[farmerId], // List of items for this farmer
          "timestamp": FieldValue.serverTimestamp(),
        };
        //print(orderData);
        await orderRef.set(orderData);
      }

      print("Orders placed successfully!");
    } catch (e) {
      print("Error placing orders: $e");
    }
  }

  Future<void> getOrderDetail(String buyerId) async {
    isFetching.value = true;
    try {
      QuerySnapshot orderSnapshot = await firestore
          .collection("orders")
          .where("buyerId", isEqualTo: buyerId)
          .orderBy("timestamp", descending: true) // Requires Index
          .limit(1)
          .get();

      if (orderSnapshot.docs.isNotEmpty) {
        orderSuccess.value =
            orderSnapshot.docs.first.data() as Map<String, dynamic>;
        //print(orderSuccess['orderId']);
      } else {
        print("No orders found for this user.");
      }
    } catch (e) {
      print("Error fetching order details: $e");
      if (e.toString().contains("[cloud_firestore/failed-precondition]")) {
        print(
            "Firestore index is missing! Please create it in the Firebase Console.");
      }
    } finally {
      isFetching.value = false;
    }
  }

  Future<void> myAllOrders(String buyerId) async {
    isFetching.value = true;
    try {
      QuerySnapshot orderSnapshot = await firestore
          .collection("orders")
          .where("buyerId", isEqualTo: buyerId)
          .orderBy("timestamp", descending: true) // Requires Index
          .get();

      if (orderSnapshot.docs.isNotEmpty) {
        myOrders.value = orderSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      } else {
        myOrders.clear();
        print("No orders found for this user.");
      }
    } catch (e) {
      print("Error fetching order details: $e");
    } finally {
      isFetching.value = false;
    }
  }
}
