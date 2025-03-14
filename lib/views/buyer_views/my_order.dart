import 'package:agribazar/controllers/buyer_controller/order_controller.dart';
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
            "Order ID: #${order['orderId'] ?? 'Unknown'}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (items.isNotEmpty) _buildProductRow(items[0]),
          const SizedBox(height: 10),
          _buildOrderButtons(),
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
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
  Widget _buildOrderButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCancelButton(),
        _buildViewDetailsButton(),
      ],
    );
  }

  /// Builds the Cancel Order button
  Widget _buildCancelButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Get.snackbar(
          "Cancel Order",
          "Order cancellation feature coming soon!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
      },
      icon: const Icon(Icons.cancel, size: 18),
      label: const Text("Cancel Order"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      ),
    );
  }

  /// Builds the View Details button
  Widget _buildViewDetailsButton() {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.arrow_forward_ios, size: 16),
      label: const Text("View Details"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow.shade800,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      ),
    );
  }
}
