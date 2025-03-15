import 'package:agribazar/controllers/farmer_controller/order_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersScreen extends StatefulWidget {
  final String farmerId;
  const OrdersScreen({super.key, required this.farmerId});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderController orderController = Get.put(OrderController());

  @override
  void initState() {
    super.initState();
    orderController.myAllOrders(widget.farmerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'Farmer Orders',
          style: GoogleFonts.abyssinicaSil(
            textStyle: const TextStyle(
                fontSize: 20, letterSpacing: .5, fontWeight: FontWeight.w700),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Obx(() => DropdownButton<String>(
                value: orderController.selectedStatus.value,
                items: ['All', 'Pending', 'Delivered']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    orderController.selectedStatus.value = value;
                  }
                },
              )),
          const SizedBox(width: 10),
        ],
      ),
      body: Obx(() {
        if (orderController.isFetching.value) {
          return const Center(child: CircularProgressIndicator());
        }

        var orders = orderController.myOrders;

        if (orders.isEmpty) {
          return const Center(child: Text("No orders found"));
        }

        // Filter orders based on selected status
        if (orderController.selectedStatus.value != 'All') {
          orders = orders
              .where((order) =>
                  order['status'] == orderController.selectedStatus.value)
              .toList()
              .obs;
        }

        if (orders.isEmpty) {
          return const Center(child: Text("No orders found for this status"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            List<dynamic> items =
                (orders[index]['items'] as List<dynamic>? ?? []);
            String status = orders[index]['status'];
            Timestamp? timestamp = orders[index]['timestamp'] as Timestamp?;
            // List of order items
            return Column(
              children: items
                  .map((item) => OrderCard(
                        orderData: item,
                        status: status,
                        timestamp: timestamp,
                      ))
                  .toList(),
            );
          },
        );
      }),
    );
  }
}

// OrderCard Widget with status & timestamp
class OrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final String status;
  final Timestamp? timestamp;

  const OrderCard(
      {super.key,
      required this.orderData,
      required this.status,
      required this.timestamp});

  @override
  Widget build(BuildContext context) {
    DateTime? orderDate = timestamp?.toDate();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                orderData['productImage'] ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 80),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderData['productname'] ?? 'Unknown Crop',
                  style: GoogleFonts.acme(
                    textStyle: const TextStyle(
                        fontSize: 16,
                        letterSpacing: .5,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Text("Quantity: ${orderData['quantity'] ?? '0'}",
                    style: const TextStyle(color: Colors.black54)),
                Text(
                    "Amount: ₹${(orderData['productPrice'] ?? 0).toStringAsFixed(2)}",
                    style: const TextStyle(color: Colors.black87)),
                Text(
                  "Status: $status",
                  style: TextStyle(
                      color: status == 'Delivered' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Column(
              children: [
                Icon(
                    status == 'Delivered'
                        ? Icons.check_circle
                        : Icons.pending_actions,
                    color: status == 'Delivered' ? Colors.green : Colors.orange,
                    size: 30),
                const SizedBox(height: 5),
                Text(
                  orderDate != null
                      ? "${orderDate.day}/${orderDate.month}/${orderDate.year}"
                      : "No Date",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
