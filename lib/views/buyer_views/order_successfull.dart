import 'package:agribazar/views/buyer_views/buyers_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
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
                  _buildDetailRow("Order ID", "#123456"),
                  _buildDetailRow("Date", "March 10, 2025"),
                  _buildDetailRow("Time", "10:30 AM"),
                  _buildDetailRow("Payment Method", "Credit Card"),
                  _buildDetailRow("Delivery Address", "123 Street, City"),
                  _buildDetailRow("Total Amount", "Rs. 1,250.00"),
                ],
              ),
            ),
            const Spacer(),
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
                )); // Navigate back to Home
              },
              child: const Text(
                "Done",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
