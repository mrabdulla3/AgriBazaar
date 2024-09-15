import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms and Conditions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Introduction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Welcome to our app! These terms and conditions outline the rules and regulations for the use of our app.',
              ),
              SizedBox(height: 16),
              Text(
                'Acceptance of Terms',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'By accessing this app, we assume you accept these terms and conditions. Do not continue to use the app if you do not agree to all of the terms and conditions stated on this page.',
              ),
              SizedBox(height: 16),
              Text(
                'Changes to Terms',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'We reserve the right to make changes to these terms and conditions at any time. Your continued use of the app following the posting of changes will mean that you accept and agree to the changes.',
              ),
              SizedBox(height: 16),
              Text(
                'User Responsibilities',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'As a user of our app, you agree to use the app responsibly and comply with all applicable laws and regulations. You also agree not to engage in any activity that could harm the app or its users.',
              ),
              SizedBox(height: 16),
              Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Our privacy policy explains how we collect, use, and protect your personal information. By using our app, you agree to the terms of our privacy policy.',
              ),
              SizedBox(height: 16),
              Text(
                'Limitation of Liability',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'To the fullest extent permitted by law, we will not be liable for any damages arising from your use of the app or your inability to use the app.',
              ),
              SizedBox(height: 16),
              Text(
                'Contact Us',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'If you have any questions or concerns about these terms and conditions, please contact us at support@example.com.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
