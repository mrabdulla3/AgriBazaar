import 'package:agribazar/user_authentication/authScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Sidebar extends StatefulWidget {
  final User? user;
  const Sidebar({required this.user, super.key});
  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  Map<String, dynamic>? userProfileData;
  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userProfileData = userDoc.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print('Error fetching user profile data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    //double screenHeight = MediaQuery.of(context).size.height / 2.1;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 230,
            child: DrawerHeader(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userProfileData != null &&
                          userProfileData!['profileImageUrl'] != null
                      ? NetworkImage(userProfileData!['profileImageUrl'])
                          as ImageProvider
                      : null, // If image doesn't exist, show icon instead
                  child: userProfileData == null ||
                          userProfileData!['profileImageUrl'] == null
                      ? const Icon(Icons.person,
                          size: 35) // Show person icon if no image
                      : null,
                ),
                Text(
                  userProfileData!['name'] ?? widget.user!.displayName,
                  style: GoogleFonts.abrilFatface(
                    textStyle: const TextStyle(fontSize: 20, letterSpacing: .5),
                  ),
                ),
                Text(
                  widget.user!.email ?? "",
                  style: GoogleFonts.aBeeZee(
                    textStyle: const TextStyle(fontSize: 20, letterSpacing: .5),
                  ),
                ),
              ],
            )),
          ),
          ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Feedback'),
              onTap: () {}),
          ListTile(
              leading: const Icon(Icons.account_box_outlined),
              title: const Text('About Us'),
              onTap: () {}),
          ListTile(
              leading: const Icon(Icons.contact_page_outlined),
              title: const Text('Contact Us'),
              onTap: () {}),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const AuthScreen(),
              ));
            },
          ),
        ],
      ),
    );
  }
}
