import 'package:agribazar/controllers/authentication_controller/signin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgotpassword.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});
  final SigninController signinController = Get.put(SigninController());

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    //double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo at the top
              SizedBox(height: screenHeight * 0.1),
              Image.asset(
                'assets/agribazar.png',
                height: 150,
                width: 150,
              ),

              const SizedBox(height: 30),
              Form(
                key: signinController.formkey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: signinController.mailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Password Field
                    Obx(() => TextFormField(
                          controller: signinController.passwordController,
                          obscureText: !signinController.passwordVisible.value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(signinController.passwordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                signinController.passwordVisible.value =
                                    !signinController.passwordVisible.value;
                              },
                            ),
                          ),
                        )),
                    const SizedBox(height: 15),
                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: signinController.isLoading.value
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFFDBE42), // Yellow color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                if (signinController.formkey.currentState!
                                    .validate()) {
                                  signinController.email =
                                      signinController.mailController.text;
                                  signinController.password =
                                      signinController.passwordController.text;

                                  signinController.userLogin();
                                }
                              },
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.aclonica(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Get.to(ForgotPassword());
                        },
                        child: Text(
                          'Forgot password?',
                          style: GoogleFonts.acme(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
