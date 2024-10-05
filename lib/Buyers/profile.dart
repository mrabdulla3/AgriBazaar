import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.2,
              width: screenWidth,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.amberAccent],
                  ),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50))),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                        'assets/avatar_placeholder.png'), // Replace with your image asset
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Anna Avetisyan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            buildProfileInfo(Icons.person, "Anna Avetisyan"),
            buildProfileInfo(Icons.cake, "Birthday"),
            buildProfileInfo(Icons.phone, "818 123 4567"),
            buildProfileInfo(Icons.camera_alt, "Instagram account"),
            buildProfileInfo(Icons.email, "info@aplusdesign.co"),
            buildProfileInfo(Icons.lock, "Password", Icons.sync),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Edit profile action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                'Edit profile',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileInfo(IconData icon, String title,
      [IconData? trailingIcon]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          if (trailingIcon != null) Icon(trailingIcon, color: Colors.amber),
        ],
      ),
    );
  }
}
