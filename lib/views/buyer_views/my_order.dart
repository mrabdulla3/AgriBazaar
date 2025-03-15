import 'package:agribazar/controllers/buyer_controller/order_controller.dart';
import 'package:agribazar/views/buyer_views/buyers_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});
  @override
  MyOrdersScreenState createState() => MyOrdersScreenState();
}

class MyOrdersScreenState extends State<MyOrdersScreen> {
  final OrderController orderController = Get.put(OrderController());

  @override
  void initState() {
    super.initState();
    final String? buyerId = FirebaseAuth.instance.currentUser?.uid;
    if (buyerId != null) {
      orderController.myAllOrders(buyerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.offAll(MarketHomePage(
                user: FirebaseAuth.instance.currentUser,
              ));
            },
            icon: const Icon(Icons.arrow_back_ios_new_outlined)),
        title: Text(
          "My Orders",
          style: GoogleFonts.abyssinicaSil(
            textStyle: const TextStyle(
                fontSize: 20, letterSpacing: .5, fontWeight: FontWeight.w700),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.yellow.shade700,
        elevation: 5,
      ),
      body: Obx(() {
        if (orderController.isFetching.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (orderController.myOrders.isEmpty) {
          return const Center(
            child: Text(
              "No orders found.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orderController.myOrders.length,
          itemBuilder: (context, index) {
            final order = orderController.myOrders[index];
            return _buildOrderItem(order);
          },
        );
      }),
    );
  }

  /// Builds an individual order item card
  Widget _buildOrderItem(Map<String, dynamic> order) {
    final List<dynamic> items = order['items'] as List<dynamic>? ?? [];
    final String docId = order['orderId'] ?? '';
    final String status = order['status'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order ID: #$docId",
            style: GoogleFonts.abyssinicaSil(
              textStyle: const TextStyle(
                  fontSize: 15, letterSpacing: .5, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          if (items.isNotEmpty) _buildProductRow(items[0]),
          const SizedBox(height: 10),
          _buildOrderButtons(status, docId),
        ],
      ),
    );
  }

  /// Builds product row inside an order item
  Widget _buildProductRow(Map<String, dynamic> item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            item['productImage'] ?? '',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, size: 80),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['productname'] ?? "Unknown Product",
                style: GoogleFonts.acme(
                  textStyle: const TextStyle(
                      fontSize: 16,
                      letterSpacing: .5,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Quantity: ${item['quantity'] ?? 0}",
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 2),
              Text(
                "Price: ₹${item['productPrice'] ?? 0}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds Cancel and View Details buttons
  Widget _buildOrderButtons(String status, String docId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCancelButton(status, docId),
        _buildDeliveredButton(status, docId),
      ],
    );
  }

  /// Builds the Cancel Order button
  Widget _buildCancelButton(String status, String docId) {
    return Obx(() {
      bool isCancelled = orderController.getOrderStatus(docId) == "cancel";
      bool isDelivered = orderController.getOrderStatus(docId) == "delivered";

      return ElevatedButton.icon(
        onPressed: isCancelled || isDelivered
            ? null
            : () async {
                await orderController.changeStatus("cancel", docId);
                orderController.updateOrderStatus(docId, "cancel"); // Update UI
              },
        icon: const Icon(Icons.cancel, size: 18),
        label: Text(
          isCancelled || isDelivered ? "Cancelled" : "Cancel Order",
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isCancelled || isDelivered ? Colors.grey : Colors.red.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        ),
      );
    });
  }

  /// Builds the View Details button
  Widget _buildDeliveredButton(String status, String docId) {
    return Obx(() {
      bool isDelivered = orderController.getOrderStatus(docId) == "Delivered";
      bool isCanceled = orderController.getOrderStatus(docId) == "cancel";
      return ElevatedButton.icon(
        onPressed: isDelivered || isCanceled
            ? null
            : () async {
                await orderController.changeStatus("Delivered", docId);
                orderController.updateOrderStatus(
                    docId, "Delivered"); // Update UI
              },
        icon: const Icon(Icons.arrow_forward_ios, size: 16),
        label: Text(isDelivered ? "Delivered" : "Not Delivered"),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDelivered || isCanceled ? Colors.grey : Colors.yellow.shade800,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        ),
      );
    });
  }
}
