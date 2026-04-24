import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/services/auth_services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final _formkey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthServices();

  bool _obscurePassword = true;

  bool isAdmin = false;
  String get selectedRole => isAdmin? "admin" : "user";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 40),

                // LOGO
                Center(
                  child: Image.asset(
                    "images/carrot.png",
                    height: 70,
                  ),
                ),

                const SizedBox(height: 80),

                // TITLE
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Create Account  🛒",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff1E1E1E),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Sign up to get started",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                //  FORM CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        // USERNAME
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_outline),
                            hintText: "Username",
                            filled: true,
                            fillColor: const Color(0xffF7F7F7),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.grey,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter username";
                            }
                            if (value.length < 3) {
                              return "Username too short";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        // EMAIL
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            hintText: "Email address",
                            filled: true,
                            fillColor: const Color(0xffF7F7F7),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.grey,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            RegExp emailRegEx = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'
                            );

                            if (value == null || value.isEmpty) {
                              return "Enter your email";
                            }

                            if (!emailRegEx.hasMatch(value)) {
                              return "Enter valid email";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        // PASSWORD
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            hintText: "Password",
                            filled: true,
                            fillColor: const Color(0xffF7F7F7),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.grey,
                                width: 1.5,
                              ),
                            ),

                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: (value) {
                            RegExp passwordRegEx = RegExp(
                                r'^(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$'
                            );

                            if (value == null || value.isEmpty) {
                              return "Enter password";
                            }

                            if (!passwordRegEx.hasMatch(value)) {
                              return "Invalid password";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 35),

                        // TERMS
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text.rich(
                            TextSpan(
                              text: "By continuing you agree to our ",
                              children: [
                                TextSpan(
                                  text: "Terms of Service",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                                const TextSpan(text: "\n and "),
                                TextSpan(
                                  text: "Privacy Policy.",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // SIGNUP BUTTON
                        ElevatedButton(
                          onPressed: signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("Sign Up"),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // LOGIN REDIRECT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/logIn');
                      },
                      child: const Text(
                        "Log In",
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void signUp() async {
    if (_formkey.currentState!.validate()) {
      try {
        final user = await _authService.signUp(
          _usernameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
          selectedRole
        );

        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Signup Success"),
            ),
          );

          Navigator.pushNamed(context, '/home');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
  }