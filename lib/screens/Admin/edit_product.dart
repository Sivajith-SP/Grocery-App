import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/models/category_model.dart';
import 'package:grocery_app/models/product_model.dart';
import 'package:grocery_app/services/product_services.dart';
import '../../services/category_services.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController titleController;
  late TextEditingController subtitleController;
  late TextEditingController priceController;
  late TextEditingController imageController;
  late TextEditingController descriptionController;
  late TextEditingController detailsController;

  bool isExclusive = false;
  bool isBestSelling = false;

  bool isLoading = false;
  bool isCategoryLoading = true;

  String? selectedCategoryId;

  List<CategoryModel> categories = [];

  final CategoryService _categoryService = CategoryService();
  final ProductServices _productService = ProductServices();

  @override
  void initState() {
    super.initState();

    // ✅ INIT VALUES
    titleController = TextEditingController(text: widget.product.title);
    subtitleController = TextEditingController(text: widget.product.subtitle);
    priceController =
        TextEditingController(text: widget.product.price.toString());
    imageController = TextEditingController(text: widget.product.image);
    descriptionController =
        TextEditingController(text: widget.product.description);
    detailsController =
        TextEditingController(text: widget.product.details);

    selectedCategoryId = widget.product.categoryId;
    isExclusive = widget.product.isExclusive;
    isBestSelling = widget.product.isBestSelling;

    fetchCategories();
  }

  void fetchCategories() async {
    final data = await _categoryService.getCategories();

    setState(() {
      categories = data;
      isCategoryLoading = false;
    });
  }

  void updateProduct() async {
    setState(() => isLoading = true);

    final updated = Product(
      id: widget.product.id,
      title: titleController.text.trim(),
      subtitle: subtitleController.text.trim(),
      price: double.parse(priceController.text),
      image: imageController.text.trim(),
      categoryId: selectedCategoryId!,
      details: detailsController.text.trim(),
      description: descriptionController.text.trim(),
      isExclusive: isExclusive,
      isBestSelling: isBestSelling,
    );

    await _productService.updateProduct(updated);

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text("Product Updated", style: TextStyle(color: Colors.white)),
      ),
    );

    Navigator.pop(context);
  }

  //  MODERN TEXT FIELD
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? type,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: type,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon) : null,
          hintText: hint,
          filled: true,
          fillColor: const Color(0xffF7F7F7),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),

          // ✅ FIXED FOCUS BORDER
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text("Edit Product"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // ✅ CARD CONTAINER (MODERN UI)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              child: Column(
                children: [
                  _buildField(
                      controller: titleController,
                      hint: "Product Title",
                      icon: Icons.shopping_bag),

                  _buildField(
                      controller: subtitleController,
                      hint: "Subtitle",
                      icon: Icons.text_fields),

                  _buildField(
                    controller: priceController,
                    hint: "Price",
                    icon: Icons.currency_rupee,
                    type: TextInputType.number,
                  ),

                  _buildField(
                      controller: imageController,
                      hint: "Image URL",
                      icon: Icons.image),

                  _buildField(
                      controller: descriptionController,
                      hint: "Description",
                      icon: Icons.description),

                  _buildField(
                    controller: detailsController,
                    hint: "Details",
                    maxLines: 3,
                  ),

                  const SizedBox(height: 10),

                  // ✅ MODERN DROPDOWN
                  isCategoryLoading
                      ? const CircularProgressIndicator()
                      : DropdownButtonFormField(
                    value: selectedCategoryId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xffF7F7F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    hint: const Text("Select Category"),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategoryId = value as String;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // ✅ SWITCHES (MODERN)
                  SwitchListTile(
                    activeColor: AppColors.primary,
                    value: isExclusive,
                    onChanged: (value) =>
                        setState(() => isExclusive = value),
                    title: const Text("Exclusive Product"),
                  ),

                  SwitchListTile(
                    activeColor: AppColors.primary,
                    value: isBestSelling,
                    onChanged: (value) =>
                        setState(() => isBestSelling = value),
                    title: const Text("Best Selling"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ✅ BUTTON
            ElevatedButton(
              onPressed: isLoading ? null : updateProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Update Product"),
            ),
          ],
        ),
      ),
    );
  }
}