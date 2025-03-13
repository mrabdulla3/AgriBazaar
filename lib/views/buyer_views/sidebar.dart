import 'package:agribazar/controllers/buyer_controller/profile_controller.dart';
import 'package:agribazar/views/authentication_views/authScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:google_fonts/google_fonts.dart';

class Sidebar extends StatefulWidget {
  final User? user;
  const Sidebar({required this.user, super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  late ProfileController profileController;

  @override
  void initState() {
    super.initState();
    profileController = Get.put(ProfileController(user: widget.user));
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height / 2.1;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: screenHeight * 0.65,
            child: profileController.userProfileData == null
                ? const Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : DrawerHeader(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              profileController.userProfileData != null &&
                                      profileController.userProfileData![
                                              'profileImageUrl'] !=
                                          null
                                  ? NetworkImage(profileController
                                          .userProfileData!['profileImageUrl'])
                                      as ImageProvider
                                  : null,
                          child: (profileController.userProfileData == null ||
                                  profileController.userProfileData![
                                          'profileImageUrl'] ==
                                      null)
                              ? const Icon(Icons.person, size: 35)
                              : null,
                        ),
                        Text(
                          profileController.userProfileData!['name'] ??
                              widget.user!.displayName ??
                              '',
                          style: GoogleFonts.abrilFatface(
                            textStyle: const TextStyle(
                                fontSize: 20, letterSpacing: .5),
                          ),
                        ),
                        Text(
                          widget.user!.email ?? "No email available",
                          style: GoogleFonts.aBeeZee(
                            textStyle: const TextStyle(
                                fontSize: 20, letterSpacing: .5),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          ListTile(
              leading: SizedBox(
                height: 25,
                width: 25,
                child: Image.asset('assets/product.png'),
              ),
              title: const Text('My Orders'),
              onTap: () {}),
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
