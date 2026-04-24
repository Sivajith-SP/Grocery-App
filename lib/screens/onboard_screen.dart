import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';


class Onboard extends StatelessWidget {
  const Onboard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOTTIE ANIMATION
              SizedBox(
                height: screenHeight * 0.35,
                width: screenWidth,
                child: Lottie.asset(
                  "animations/delivery.json",
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 40),

              // TITLE
               Text(
                "Welcome \nto our store",
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                  fontSize: 26.sp,
                  color: Color(0xff1E1E1E),
                ),
              ),

              const SizedBox(height: 12),

              // SUBTITLE
              Text(
                "Get your groceries in as fast as one hour",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 100),

              // BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async{
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool("hasSeenOnboarding", true);
                    Navigator.pushNamed(context, '/logIn');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
