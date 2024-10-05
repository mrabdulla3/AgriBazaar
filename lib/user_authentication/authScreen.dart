import 'package:flutter/material.dart';
import 'signin_page.dart';
import 'signup_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login/Signup UI',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isLogin ? SignInPage() : SignUpPage(),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            setState(() {
              isLogin = !isLogin;
            });
          },
          child: Text(
            isLogin
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
    );
  }
}
