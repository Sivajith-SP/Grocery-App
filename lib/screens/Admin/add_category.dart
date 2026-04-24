import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/models/category_model.dart';
import '../../services/category_services.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final nameController = TextEditingController();
  final imageController = TextEditingController();
  final CategoryService _categoryService = CategoryService();

  Color selectedCardColor = Colors.green.shade100;
  Color selectedBorderColor = Colors.green;

  void addCategory() async {
    if (nameController.text.isEmpty || imageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    final category = CategoryModel(
      id: '',
      name: nameController.text.trim(),
      image: imageController.text.trim(),
    );

    final success = await _categoryService.addCategory(category);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Category Added")),
      );

      nameController.clear();
      imageController.clear();

      setState(() {
        selectedCardColor = Colors.green.shade100;
        selectedBorderColor = Colors.green;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Add Category",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xff1E1E1E),
          ),
        ),
      ),

      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              // FORM CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
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

                    /// NAME FIELD
                    TextField(
                      controller: nameController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Category name",
                        prefixIcon: const Icon(Icons.category_outlined),
                        filled: true,
                        fillColor: const Color(0xffF7F7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// IMAGE FIELD
                    TextField(
                      controller: imageController,
                      decoration: InputDecoration(
                        hintText: "Image URL",
                        prefixIcon: const Icon(Icons.image_outlined),
                        filled: true,
                        fillColor: const Color(0xffF7F7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: addCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text("Add Category"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }
}
