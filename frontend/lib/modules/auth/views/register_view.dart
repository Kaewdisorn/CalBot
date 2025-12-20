import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [_logoSection(), _registerCardSection(theme)]),
          ),
        ),
      ),
    );
  }

  Widget _logoSection() {
    return Transform.translate(offset: const Offset(0, -10), child: Image.asset(controller.logoImgPath, height: 120));
  }

  Widget _registerCardSection(ThemeData theme) {
    return Transform.translate(
      offset: const Offset(0, -35),
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
              const Text("Create your account"),
              const SizedBox(height: 32),

              // Username Field
              TextField(
                // controller: controller.nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // User Email Field
              TextField(
                // controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Password Field
              Obx(
                () => TextField(
                  // controller: controller.passwordController,
                  obscureText: !controller.isPasswordVisible.value,
                  textInputAction: TextInputAction.next,
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
              const SizedBox(height: 16),

              // Confirm Password Field
              Obx(
                () => TextField(
                  // controller: controller.confirmPasswordController, // Add controller here
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    // Slightly different icon to differentiate
                    prefixIcon: const Icon(Icons.lock_clock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(controller.isConfirmPasswordVisible.value ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => controller.isConfirmPasswordVisible.toggle(),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Register Button
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
                  child: const Text("REGISTER", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),

              // Back to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.brown[700], fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
