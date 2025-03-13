import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signin_page.dart';
import 'signup_page.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  RxBool isLogin = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Obx(
        () => AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLogin.value ? SignInPage() : SignUpPage(),
        ),
      )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(
          () => GestureDetector(
            onTap: () {
              isLogin.value = !isLogin.value;
            },
            child: Text(
              isLogin.value
                  ? "Don't have an account? Sign Up"
                  : "Already have an account? Sign In",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blue.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
