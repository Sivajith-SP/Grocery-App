import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/services/auth_services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _authService = AuthServices();

  bool isLoading = false;

  Future<void> sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email")),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await _authService.resetPassword(email);

    setState(() => isLoading = false);

    if (result == true) {
      Navigator.pushReplacementNamed(
        context,
        '/resetConfirmation',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            const Text(
              "Enter your email address to receive a password reset link.",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: "Email address",
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: isLoading ? null : sendResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 55),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Send Reset Link"),
            ),
          ],
        ),
      ),
    );
  }
}

//reset confirmation screen
class ResetConfirmationScreen extends StatelessWidget {
  const ResetConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //  Get email from arguments
    final email =
    ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                size: 80,
              ),

              const SizedBox(height: 20),

              const Text(
                "Password Reset Email Sent",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              //  SHOW EMAIL
              Text(
                email != null
                    ? "We sent a reset link to:\n$email"
                    : "Please check your email inbox.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/logIn',
                        (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: const Text("Back to Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}