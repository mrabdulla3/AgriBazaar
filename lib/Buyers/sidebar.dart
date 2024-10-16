import 'package:agribazar/user_authentication/authScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height / 2.1;
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
                const CircleAvatar(
                  backgroundImage: AssetImage(''),
                  radius: 50,
                ),
                Text(
                  'AgriBazaar',
                  style: GoogleFonts.abrilFatface(
                    textStyle: const TextStyle(fontSize: 20, letterSpacing: .5),
                  ),
                ),
                Text(
                  'By Abdulla Gaur',
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
