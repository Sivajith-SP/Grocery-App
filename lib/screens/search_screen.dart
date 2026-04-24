import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/models/product_model.dart';
import 'package:grocery_app/widgets/product_card.dart';

import '../widgets/product_grid_shimmer.dart';

class SearchScreen extends StatefulWidget {
  final List<Product> products;

  const SearchScreen({super.key, required this.products});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController controller = TextEditingController();

  List<Product> filtered = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // simulate loading (or use real API delay)
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        filtered = widget.products;
        isLoading = false;
      });
    });
  }

  //  SEARCH FUNCTION
  void search(String query) {
    final input = query.toLowerCase();

    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        filtered = widget.products.where((product) {
          return product.title.toLowerCase().contains(input) ||
              product.subtitle.toLowerCase().contains(input) ||
              product.description.toLowerCase().contains(input);
        }).toList();

        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          //SEARCH BOX
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),

                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      onChanged: search,
                      decoration: const InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey),
                        hintText: "Search products...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  // CLEAR BUTTON
                  if (controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        controller.clear();
                        search("");
                      },
                      child: const Icon(Icons.close, size: 18),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          //PRODUCT RESULTS
          Expanded(
            child: isLoading
                ? const ProductGridShimmer()
                : filtered.isEmpty
                ? _emptyState()
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtered.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.66,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (context, index) {
                      final product = filtered[index];

                      return ProductCard(product: product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // EMPTY STATE
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No Products found",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
