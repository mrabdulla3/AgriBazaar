import 'package:agribazar/controllers/authentication_controller/signup_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'terms_and_conditions.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});
  final SignupController signupController = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: signupController.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.1),
                // Logo at the top
                Image.asset(
                  'assets/agribazar.png',
                  height: 150,
                  width: 150,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: screenWidth * 0.9,
                  child: TextFormField(
                    controller: signupController.nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Email Field
                SizedBox(
                  width: screenWidth * 0.9,
                  child: TextFormField(
                    controller: signupController.mailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.mail),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),

                // Password Field
                SizedBox(
                    width: screenWidth * 0.9,
                    child: Obx(
                      () => TextFormField(
                        controller: signupController.passwordController,
                        obscureText: !signupController.passwordVisible.value,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(signupController.passwordVisible.value
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              signupController.passwordVisible.value =
                                  !signupController.passwordVisible.value;
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the password';
                          }
                          return null;
                        },
                      ),
                    )),
                const SizedBox(height: 15),

                // User Type Drop-down
                SizedBox(
                    width: screenWidth * 0.9,
                    child: Obx(
                      () => DropdownButtonFormField<String>(
                        value: signupController.userType.value,
                        decoration: const InputDecoration(
                          labelText: 'User Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: ['Farmer', 'Buyer']
                            .map((String type) => DropdownMenuItem<String>(
                                value: type, child: Text(type)))
                            .toList(),
                        onChanged: (String? newValue) {
                          signupController.userType.value = newValue!;
                        },
                      ),
                    )),
                const SizedBox(height: 15),

                // Terms & Conditions
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Obx(
                      () => Checkbox(
                          value: signupController.isChecked.value,
                          onChanged: (bool? value) {
                            signupController.isChecked.value = value ?? false;
                          }),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(const TermsAndConditionsPage());
                      },
                      child: Text(
                        'Terms & Conditions',
                        style: GoogleFonts.abyssinicaSil(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sign Up Button
                SizedBox(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.06,
                  child: Obx(
                    () => signupController.isLoading.value
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              if (signupController.formKey.currentState!
                                      .validate() &&
                                  signupController.isChecked.value) {
                                signupController.name.value =
                                    signupController.nameController.text;
                                signupController.email.value =
                                    signupController.mailController.text;
                                signupController.password.value =
                                    signupController.passwordController.text;

                                signupController.registration();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Please accept the terms and conditions")));
                              }
                            },
                            child: const Text(
                              'Sign Up',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
