import 'package:agribazar/controllers/buyer_controller/order_controller.dart';
import 'package:agribazar/views/buyer_views/buyers_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  final OrderController orderController = Get.put(OrderController());

  @override
  void initState() {
    super.initState();
    orderController.getOrderDetail(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Order Details",
          style: GoogleFonts.abyssinicaSil(
            textStyle: const TextStyle(
                fontSize: 20, letterSpacing: .5, fontWeight: FontWeight.w700),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (orderController.isFetching.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final orderData = orderController.orderSuccess;
        if (orderData.isEmpty) {
          return const Center(child: Text("No order details found."));
        }

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Icon
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green.shade100,
                child: const Icon(Icons.check, size: 50, color: Colors.green),
              ),
              const SizedBox(height: 10),
              const Text(
                "Order Successful",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Your order has been placed successfully!",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Order Details Section
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 5),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Order ID", orderData['orderId'] ?? 'N/A'),
                    _buildDetailRow("Status", orderData['status'] ?? 'Pending'),
                    _buildDetailRow("Timestamp",
                        orderData['timestamp']?.toString() ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Done Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Get.offAll(MarketHomePage(
                    user: FirebaseAuth.instance.currentUser,
                  ));
                },
                child: const Text(
                  "Done",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              child: Text(title, style: const TextStyle(color: Colors.grey))),
          Flexible(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
