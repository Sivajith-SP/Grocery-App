import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/services/auth_services.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formkey = GlobalKey<FormState>();
  final _authService = AuthServices();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool isAdmin = false;

  String get selectedRole => isAdmin ? "admin" : "user";

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
                Center(child: Image.asset("images/carrot.png", height: 70)),

                const SizedBox(height: 80),

                // TITLE
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Welcome Back 👋",
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
                    "Login to your account",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                ),

                const SizedBox(height: 30),

                // FORM CARD
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
                        //  TOGGLE (USER / ADMIN)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // USER
                                _buildToggleItem(
                                  title: "User",
                                  selected: !isAdmin,
                                  onTap: () {
                                    setState(() => isAdmin = false);
                                  },
                                ),
                                SizedBox(width: 8),
                                // ADMIN
                                _buildToggleItem(
                                  title: "Admin",
                                  selected: isAdmin,
                                  onTap: () {
                                    setState(() => isAdmin = true);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

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
                              borderSide: BorderSide(color: AppColors.grey),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter your email";
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
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.grey),
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
                            if (value == null || value.isEmpty) {
                              return "Enter your password";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        // FORGOT PASSWORD
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgotPassword');
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// LOGIN BUTTON
                        ElevatedButton(
                          onPressed: logIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("Log In"),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // SIGN UP
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signUp');
                      },
                      child: const Text(
                        "Sign Up",
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

  //  TOGGLE ITEM
  Widget _buildToggleItem({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? Colors.white : Colors.grey),
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // LOGIN LOGIC
  void logIn() async {
    if (_formkey.currentState!.validate()) {
      final user = await _authService.logIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        selectedRole,
      );

      if (user != null) {
        if (isAdmin) {
          if (user.email == "admin@gmail.com") {
            Navigator.pushNamed(context, "/adminhome");
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Not an Admin Account")),
            );
          }
        } else {
          Navigator.pushNamed(context, "/home");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Login Success"),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login Failed")));
      }
    }
  }

  void forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Email Enter First")),
      );
      return;
    }
    final result = await _authService.resetPassword(email);

    if(result == true){
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Password Reset Email Send")),
      );
    } else{
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.toString()),
      ),
      );
      }
  }
}
