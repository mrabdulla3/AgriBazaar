import 'package:agribazar/Farmer/crop_form_detail.dart';
import 'package:flutter/material.dart';

class CropCategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('What crops are you offering?'),
        backgroundColor: const Color(0xFFFDBE42),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Close action
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: <Widget>[
            buildCategoryCard(
                context, Icons.grass, 'Wheat'), // Passing context here
            buildCategoryCard(context, Icons.eco, 'Rice'),
            buildCategoryCard(context, Icons.agriculture, 'Maize'),
            buildCategoryCard(context, Icons.local_florist, 'Fruits'),
            buildCategoryCard(context, Icons.spa, 'Vegetables'),
            buildCategoryCard(context, Icons.apps, 'More Categories'),
          ],
        ),
      ),
    );
  }

  // Now context is being passed correctly as a parameter
  Widget buildCategoryCard(BuildContext context, IconData icon, String title) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: InkWell(
        onTap: () {
          // Handle category tap
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CropDetailsPage(
                cropType: title,
              ), // Navigates to CropDetailsPage
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.teal,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CropCategoriesPage(),
  ));
}
