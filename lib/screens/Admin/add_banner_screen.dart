import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';

class AddBannerScreen extends StatefulWidget {
  const AddBannerScreen({super.key});

  @override
  State<AddBannerScreen> createState() => _AddBannerScreenState();
}

class _AddBannerScreenState extends State<AddBannerScreen> {
  final titleController = TextEditingController();
  final imageController = TextEditingController();

  bool isLoading = false;

  void addBanner() async {
    if (titleController.text.isEmpty || imageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    //CRUD create
    await FirebaseFirestore.instance.collection('banners').add({
      'title': titleController.text.trim(),
      'image': imageController.text.trim(),
    });

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: const Text("Banner Added"),
      ),
    );

    titleController.clear();
    imageController.clear();
    setState(() {});
  }

  //  COMMON INPUT STYLE
  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hint,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Add Banner"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
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

          child: Column(
            children: [
              // TITLE
              TextField(
                controller: titleController,
                decoration: inputDecoration("Banner Title", Icons.text_fields),
              ),

              const SizedBox(height: 15),

              // IMAGE URL
              TextField(
                controller: imageController,
                onChanged: (_) => setState(() {}), //  live preview
                decoration: inputDecoration("Image URL", Icons.image),
              ),

              const SizedBox(height: 20),

              // IMAGE PREVIEW
              if (imageController.text.isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text("Invalid Image URL"));
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              // BUTTON
              ElevatedButton(
                onPressed: isLoading ? null : addBanner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Banner"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}