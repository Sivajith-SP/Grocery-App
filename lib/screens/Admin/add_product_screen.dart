import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/models/category_model.dart';
import 'package:grocery_app/models/product_model.dart';
import 'package:grocery_app/services/product_services.dart';
import 'package:provider/provider.dart';
import '../../provider/category_provider.dart';
import '../../provider/product_provider.dart';
import '../../services/category_services.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final priceController = TextEditingController();
  final imageController = TextEditingController();
  final descriptionController = TextEditingController();
  final detailsController = TextEditingController();

  bool isExclusive = false;
  bool isBestSelling = false;

  bool isCategoryLoading = true;

  String? selectedCategoryId;

  // List<CategoryModel> categories = [];

  // final CategoryService _categoryService = CategoryService();


  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  //fetch category
  void fetchCategories() async {
    final categoryProvider = Provider.of<CategoryProvider>(context,listen: false);
    await categoryProvider.fetchCategory();
    setState(() {
      // categories = data;
      isCategoryLoading = false;
    });
  }

  void addProduct() async {
    if (selectedCategoryId == null ||
        titleController.text.isEmpty ||
        imageController.text.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    final productProvider =
    Provider.of<ProductProvider>(context, listen: false);

    final product = Product(
      id: '',
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

    final success = await productProvider.addProduct(product);


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        content: Text(success ? "Product Added" : "Failed to add product"),
        backgroundColor: success ? AppColors.primary : Colors.red,
      ),
    );
  }

  //  INPUT DECORATION
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

  void clearFields() {
    titleController.clear();
    subtitleController.clear();
    priceController.clear();
    imageController.clear();
    detailsController.clear();
    descriptionController.clear();
    setState(() {
      selectedCategoryId = null;
      isExclusive = false;
      isBestSelling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Add Product"),
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
                decoration: inputDecoration(
                  "Product Title",
                  Icons.shopping_bag,
                ),
              ),

              const SizedBox(height: 15),

              // SUBTITLE
              TextField(
                controller: subtitleController,
                decoration: inputDecoration("Subtitle", Icons.text_fields),
              ),

              const SizedBox(height: 15),

              // PRICE
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: inputDecoration("Price", Icons.currency_rupee),
              ),

              const SizedBox(height: 15),

              // IMAGE
              TextField(
                controller: imageController,
                decoration: inputDecoration("Image URL", Icons.image),
              ),

              const SizedBox(height: 15),

              // DESCRIPTION
              TextField(
                controller: descriptionController,
                decoration: inputDecoration("Description", Icons.description),
              ),

              const SizedBox(height: 15),

              //DETAILS
              TextField(
                controller: detailsController,
                maxLines: 3,
                decoration: inputDecoration("Details", Icons.notes),
              ),

              const SizedBox(height: 20),

              //CATEGORY DROPDOWN
              isCategoryLoading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField(
                      initialValue: selectedCategoryId,
                      decoration: inputDecoration(
                        "Select Category",
                        Icons.category,
                      ),
                      items: categoryProvider.categories.map((cat) {
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

              const SizedBox(height: 15),

              // SWITCHES
              SwitchListTile(
                value: isExclusive,
                activeThumbColor: AppColors.primary,
                title: const Text("Exclusive Product"),
                onChanged: (val) => setState(() => isExclusive = val),
              ),

              SwitchListTile(
                value: isBestSelling,
                activeThumbColor: AppColors.primary,
                title: const Text("Best Selling"),
                onChanged: (val) => setState(() => isBestSelling = val),
              ),

              const SizedBox(height: 25),

              // BUTTON
              ElevatedButton(
                onPressed: productProvider.isLoading ? null : addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: productProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Add Product"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
