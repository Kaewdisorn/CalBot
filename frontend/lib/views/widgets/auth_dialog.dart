import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/widgets_controller/auth_controller.dart';

class AuthDialog extends StatelessWidget {
  const AuthDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 450.0 : screenWidth * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: Obx(() {
          final isLogin = controller.isLogin.value;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isLogin ? [Colors.blue.shade50, Colors.white] : [Colors.purple.shade50, Colors.white],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: (isLogin ? Colors.blue : Colors.purple).withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 5)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Icon Section
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(isLogin),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isLogin ? [Colors.blue.shade400, Colors.blue.shade600] : [Colors.purple.shade400, Colors.purple.shade600],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(isLogin ? Icons.login_rounded : Icons.person_add_rounded, size: 48, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title with animated color
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold, color: isLogin ? Colors.blue.shade700 : Colors.purple.shade700),
                      child: Text(isLogin ? 'Welcome Back!' : 'Join CalBot', textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        isLogin ? 'Sign in to continue managing your calendar' : 'Create an account to get started',
                        key: ValueKey(isLogin),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email Field
                    _ModernTextField(
                      controller: controller.emailController,
                      label: 'Email Address',
                      hint: 'Enter your email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !controller.isLoading.value,
                      accentColor: isLogin ? Colors.blue.shade600 : Colors.purple.shade600,
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    _ModernTextField(
                      controller: controller.passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      enabled: !controller.isLoading.value,
                      accentColor: isLogin ? Colors.blue.shade600 : Colors.purple.shade600,
                    ),

                    // Forgot Password (Login only)
                    if (isLogin) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: controller.isLoading.value ? null : () {},
                          child: Text('Forgot Password?', style: TextStyle(color: Colors.blue.shade600, fontSize: 13)),
                        ),
                      ),
                    ] else
                      const SizedBox(height: 24),

                    const SizedBox(height: 8),

                    // Main Action Button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isLogin ? [Colors.blue.shade400, Colors.blue.shade600] : [Colors.purple.shade400, Colors.purple.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: (isLogin ? Colors.blue : Colors.purple).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    isLogin ? 'Sign In' : 'Create Account',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Toggle Auth Mode
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: TextButton(
                        key: ValueKey(isLogin),
                        onPressed: controller.isLoading.value ? null : controller.toggleAuthMode,
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: isLogin ? "Don't have an account? " : 'Already have an account? ',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              TextSpan(
                                text: isLogin ? 'Sign Up' : 'Sign In',
                                style: TextStyle(color: isLogin ? Colors.purple.shade600 : Colors.blue.shade600, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Divider
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                        ],
                      ),
                    ),

                    // Guest Button
                    OutlinedButton(
                      onPressed: controller.isLoading.value ? null : controller.handleGuest,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline, size: 20, color: Colors.grey.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Continue as Guest',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// Modern TextField Widget
class _ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool enabled;
  final Color accentColor;

  const _ModernTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: accentColor, size: 22),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }
}
