import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- BEAR LOGO SECTION ---
                Transform.translate(
                  offset: const Offset(0, -10), // Logo position adjustment
                  child: Image.asset('assets/images/halulu_128x128.png', height: 120),
                ),

                // --- LOGIN CARD ---
                Transform.translate(
                  offset: const Offset(0, -35), // Card position adjustment
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Halulu",
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.brown[700], letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 8),
                          const Text("Welcome! Please login"),
                          const SizedBox(height: 32),

                          // Username Field
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          Obx(
                            () => TextField(
                              obscureText: !controller.isPasswordVisible.value,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () => controller.isPasswordVisible.toggle(),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(onPressed: () {}, child: const Text("Forgot Password?")),
                          ),
                          const SizedBox(height: 20),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD54F),
                                foregroundColor: Colors.brown[900],
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {},
                              child: const Text("LOGIN", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {},
                              child: const Text("Create an Account"),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // --- DIVIDER LINE ---
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text("OR", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Guest Login Button
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.person_search_rounded),
                              label: const Text("Continue as Guest"),
                              style: TextButton.styleFrom(foregroundColor: Colors.grey[700], padding: const EdgeInsets.symmetric(vertical: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
