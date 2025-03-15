import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  RxList<Map<String, dynamic>> myOrders = <Map<String, dynamic>>[].obs;
  RxBool isFetching = false.obs;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  RxString selectedStatus = 'All'.obs;

  Future<void> myAllOrders(String farmerId) async {
    // print(farmerId);
    isFetching.value = true;
    try {
      QuerySnapshot orderSnapshot = await firestore
          .collection("orders")
          .where("farmerId", isEqualTo: farmerId)
          .orderBy("timestamp", descending: true) // Requires Index
          .get();
      if (orderSnapshot.docs.isNotEmpty) {
        myOrders.value = orderSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        // print(myOrders);
      } else {
        myOrders.clear();
        // print("No orders found for this user.");
      }
    } catch (e) {
      // print("Error fetching order details: $e");
    } finally {
      isFetching.value = false;
    }
  }

  Future<void> changeStatus(String newStatus, String docId) async {
    try {
      DocumentReference orderDoc =
          FirebaseFirestore.instance.collection('orders').doc(docId);

      await orderDoc.update({'status': newStatus});

      print("Order status updated to: $newStatus");
    } catch (e) {
      print("Error changing status: $e");
    }
  }

  void updateOrderStatus(String docId, String newStatus) {
    int index = myOrders.indexWhere((order) => order['orderId'] == docId);
    if (index != -1) {
      myOrders[index]['status'] = newStatus;
      myOrders.refresh(); // Notify UI to refresh
    }
  }

  String getOrderStatus(String docId) {
    var order = myOrders.firstWhereOrNull((order) => order['orderId'] == docId);
    return order?['status'] ?? "";
  }
}
