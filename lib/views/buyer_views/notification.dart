import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.abyssinicaSil(
            textStyle: const TextStyle(
                fontSize: 20, letterSpacing: .5, fontWeight: FontWeight.w700),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            _buildNotificationSection("Today", [
              _buildNotificationTile(
                profileImage: 'assets/user1.png',
                message:
                    'You received a payment of \$860.00 from Yogie Ismanda',
                time: '09:20 AM',
                hasAction: true,
              ),
              _buildNotificationTile(
                profileImage: 'assets/user2.png',
                message: 'Avian Rizky requested a payment of \$200.00',
                time: '08:46 AM',
                hasAction: true,
              ),
            ]),
            _buildNotificationSection("Yesterday", [
              _buildNotificationTile(
                profileImage: 'assets/user3.png',
                message:
                    'You received a payment of \$860.00 from Ozi Adam Ismanda',
                time: '09:20 AM',
              ),
            ]),
            _buildNotificationSection("This Weekend", [
              _buildNotificationTile(
                profileImage: 'assets/alert.png',
                message: 'Your monthly expense almost broke the budget',
                time: 'Mar 26, 2019 at 09:20 AM',
                isAlert: true,
              ),
              _buildNotificationTile(
                profileImage: 'assets/user4.png',
                message: 'Geovanni William requested a payment of \$200.00',
                time: 'Mar 22, 2019 at 09:06 AM',
                hasAction: true,
              ),
              _buildNotificationTile(
                profileImage: 'assets/user5.png',
                message:
                    'You received a payment of \$860.00 from Indro Kharisma',
                time: 'Mar 22, 2019 at 09:06 AM',
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(String title, List<Widget> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...notifications,
      ],
    );
  }

  Widget _buildNotificationTile({
    required String profileImage,
    required String message,
    required String time,
    bool isAlert = false,
    bool hasAction = false,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(profileImage),
      ),
      title: Text(
        message,
        style: TextStyle(
          color: isAlert ? Colors.red : Colors.black,
          fontWeight: isAlert ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        time,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: hasAction
          ? ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, // button color
              ),
              child: const Text('Pay'),
            )
          : null,
    );
  }
}
