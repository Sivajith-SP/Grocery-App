import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/screens/onboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    //  ANIMATION CONTROLLER
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // SCALE ANIMATION (LOGO POP)
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    //  FADE ANIMATION
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    checkandNavigate();
  }


  Future<void> checkandNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    bool hasSeenOnboarding = prefs.getBool("hasSeenOnboarding") ?? false;

    if (!mounted) return;

    // ✅ USER LOGGED IN
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = doc.data()?['role'] ?? 'user';

      if (role == "admin") {
        Navigator.pushReplacementNamed(context, '/adminhome');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
      return;
    }

    // ❌ NOT LOGGED IN

    if (!hasSeenOnboarding) {
      // 👉 FIRST TIME → show onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Onboard()),
      );
    } else {
      // 👉 NOT FIRST TIME → go login
      Navigator.pushReplacementNamed(context, '/logIn');
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                //  LOGO CONTAINER
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    "images/urban_basket_logo.png",
                    height: 100,
                    width: 100,
                  ),
                ),

                const SizedBox(height: 25),

                //  APP NAME
                SvgPicture.asset(
                  "images/urban_basket_txt_logo.svg",
                  width: 70,
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    AppColors.accent.withOpacity(0.8),
                    BlendMode.srcIn,
                  ),
                ),

                const SizedBox(height: 10),

                //  TAGLINE
                Text(
                  "Online Groceries",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    letterSpacing: 5,
                  ),
                ),

                const SizedBox(height: 40),

              ],
            ),
          ),
        ),
      ),
    );
  }
}