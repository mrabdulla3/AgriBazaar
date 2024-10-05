import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  int macbookQty = 1;
  int airpodsQty = 1;
  bool isPickup = false;

  double macbookPrice = 1149.00;
  double airpodsPrice = 100.00;
  double deliveryCharge = 30.00;

  @override
  Widget build(BuildContext context) {
    double subtotal = (macbookPrice * macbookQty) + (airpodsPrice * airpodsQty);
    double total = subtotal + (isPickup ? 0 : deliveryCharge);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My cart",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildCartItems(),
              const SizedBox(height: 20),
              _buildDeliveryOption(),
              const SizedBox(height: 20),
              _buildDeliveryDetails(),
              const SizedBox(height: 20),
              _buildPriceDetails(subtotal, total),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildPaymentButton(total),
      ),
    );
  }

  Widget _buildCartItems() {
    return Column(
      children: [
        _buildCartItem(
          imageUrl: 'assets/splashImg.jpg',
          title: 'Apple Macbook Pro 2020 M1',
          price: macbookPrice,
          quantity: macbookQty,
          onAdd: () {
            setState(() {
              macbookQty++;
            });
          },
          onRemove: () {
            if (macbookQty > 1) {
              setState(() {
                macbookQty--;
              });
            }
          },
        ),
        const Divider(),
        _buildCartItem(
          imageUrl: 'assets/splashImg.jpg',
          title: 'Apple Airpods 2020',
          price: airpodsPrice,
          quantity: airpodsQty,
          onAdd: () {
            setState(() {
              airpodsQty++;
            });
          },
          onRemove: () {
            if (airpodsQty > 1) {
              setState(() {
                airpodsQty--;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildCartItem({
    required String imageUrl,
    required String title,
    required double price,
    required int quantity,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Row(
      children: [
        Image.asset(imageUrl, width: 50, height: 50),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon:
                  const Icon(Icons.remove_circle_outline, color: Colors.amber),
              onPressed: onRemove,
            ),
            Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.amber),
              onPressed: onAdd,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDeliveryTypeButton("Pickup", isPickup),
        _buildDeliveryTypeButton("Delivery", !isPickup),
      ],
    );
  }

  Widget _buildDeliveryTypeButton(String title, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isPickup = title == "Pickup";
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.amber : Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Delivery to",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "149, Sunset Ave, Los Angeles, CA",
              style: TextStyle(fontSize: 14),
            ),
            GestureDetector(
              onTap: () {
                // Implement edit address functionality
              },
              child: const Text(
                "Edit",
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "FedEx Express, Friday 28 July",
              style: TextStyle(fontSize: 14),
            ),
            GestureDetector(
              onTap: () {
                // Implement edit delivery option functionality
              },
              child: const Text(
                "Edit",
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceDetails(double subtotal, double total) {
    return Column(
      children: [
        _buildPriceRow("Subtotal", subtotal),
        _buildPriceRow("Delivery", isPickup ? 0 : deliveryCharge),
        const Divider(),
        _buildPriceRow("Total", total, isBold: true),
      ],
    );
  }

  Widget _buildPriceRow(String title, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(double total) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Implement payment functionality
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          "Pay \$${total.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
