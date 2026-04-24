

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';

class MyDetailsScreen extends StatefulWidget {
  const MyDetailsScreen({super.key});

  @override
  State<MyDetailsScreen> createState() => _MyDetailsScreenState();
}

class _MyDetailsScreenState extends State<MyDetailsScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    final doc =
    await firestore.collection('users').doc(user!.uid).get();

    final data = doc.data();

    nameController.text = data?['username'] ?? "";
    emailController.text = data?['email'] ?? "";

    setState(() {
      isLoading = false;
    });
  }

  void updateUser() async {
    await firestore.collection('users').doc(user!.uid).update({
      "username": nameController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(

       SnackBar(content: Text("Profile updated",style: TextStyle(color: AppColors.white),),backgroundColor: AppColors.primary,duration: Duration(seconds: 1),),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Details"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Email (readonly)
            TextField(
              controller: emailController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: updateUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF7A00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}