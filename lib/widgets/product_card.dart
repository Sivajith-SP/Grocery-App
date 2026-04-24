import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/models/cart_model.dart';
import 'package:grocery_app/models/product_model.dart';
import 'package:grocery_app/services/cart_services.dart';
import 'package:grocery_app/widgets/qty_btn.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../models/favourite_model.dart';
import '../services/favourite_services.dart';

// PRODUCT CARD
class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final CartServices _cartService = CartServices();

  int qty = 0;

  //  ADD ITEM
  void addItem() async {
    setState(() => qty = 1);

    final cartItem = CartModel.fromProduct(widget.product, 1);
    await _cartService.addToCartProduct(cartItem);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SecondScreen(product: widget.product),
          ),
        );
      },
      child: SizedBox(
        height: 260,
        width: 180,
        child: Card(
          color: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// IMAGE
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.product.image,
                        fit: BoxFit.scaleDown,
                        width: double.infinity,

                        //  SHIMMER LOADING
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;

                          return Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              width: double.infinity,
                              color: Colors.white,
                            ),
                          );
                        },

                        //  ERROR (NO INTERNET)
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  //TITLE
                  Text(
                    widget.product.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // SUBTITLE
                  Text(
                    widget.product.subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),

                  const SizedBox(height: 10),

                  // PRICE + BUTTON
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\₹${widget.product.price}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      // add btn
                      GestureDetector(
                        onTap: () async {
                          final cartService = CartServices();

                          final cartItem = CartModel.fromProduct(
                            widget.product,
                            1,
                          );
                          final success = await cartService.addToCartProduct(
                            cartItem,
                          );

                          HapticFeedback.lightImpact();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: Duration(microseconds: 900),
                              backgroundColor: success
                                  ? AppColors.primary
                                  : Colors.red,
                              content: Text(
                                success ? "Added to cart" : "Failed",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xffFF7A00),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// PRODUCT DETAILS SCREEN

class SecondScreen extends StatefulWidget {
  final Product product;

  const SecondScreen({super.key, required this.product});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final CartServices _cartService = CartServices();
  final FavouriteServices _favService = FavouriteServices();

  int qty = 1;

  bool isFavourite = false;
  bool isLoadingFav = true;

  /// ================== INIT ==================
  @override
  void initState() {
    super.initState();
    checkFavourite();
  }

  void checkFavourite() async {
    final result = await _favService.isFavourite(widget.product.id);
    setState(() {
      isFavourite = result;
      isLoadingFav = false;
    });
  }

  /// ================== QTY ==================
  void onAdd() => setState(() => qty++);

  void onRemove() {
    if (qty > 1) setState(() => qty--);
  }

  /// ================== CART ==================
  void addToCartProduct() async {
    final cartItem = CartModel.fromProduct(widget.product, qty);

    final success = await _cartService.addToCartProduct(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Added to cart" : "Failed"),
        backgroundColor: success ? AppColors.primary : Colors.red,
      ),
    );
  }

  /// ================== FAVOURITE ==================
  void toggleFavourite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final fav = FavouriteModel(
      userId: user.uid,
      productId: widget.product.id,
      title: widget.product.description,
      subtitle: widget.product.subtitle,
      image: widget.product.image,
      price: widget.product.price,
    );

    await _favService.toggleFavourite(fav);

    setState(() {
      isFavourite = !isFavourite;
    });
  }

  /// ================== UI ==================
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            /// ================= IMAGE =================
            Stack(
              children: [
                Container(
                  height: screenHeight * 0.35,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(25),
                    ),
                  ),
                  child:
                  Image.network(
                    widget.product.image,
                    fit: BoxFit.contain,

                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;

                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                      );
                    },

                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 40),
                        ),
                      );
                    },
                  ),
                ),

                /// BACK
                Positioned(
                  left: 15,
                  top: 10,
                  child: _iconBtn(Icons.arrow_back, () {
                    Navigator.pop(context);
                  }),
                ),

                /// SHARE
                Positioned(
                  right: 15,
                  top: 10,
                  child: _iconBtn(Icons.ios_share, () {}),
                ),
              ],
            ),

            /// ================= DETAILS =================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),

                    /// TITLE + FAV
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.description,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff1E1E1E),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// ❤️ FAV
                        isLoadingFav
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : GestureDetector(
                                onTap: toggleFavourite,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isFavourite
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFavourite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavourite
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      widget.product.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ================= PRICE + QTY =================
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// QTY
                          Row(
                            children: [
                              qtyButton(Icons.remove, onRemove),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  qty.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              qtyButton(Icons.add, onAdd, isAdd: true),
                            ],
                          ),

                          /// PRICE
                          Text(
                            "₹${widget.product.price}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ================= DETAILS CARD =================
                    _sectionCard(
                      title: "Product Details",
                      child: Text(
                        widget.product.details,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// ================= NUTRITION =================
                    _sectionCard(
                      title: "Nutrition",
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffFFF3E6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text("100g"),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// ================= REVIEW =================
                    _sectionCard(
                      title: "Review",
                      trailing: Row(
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            Icons.star,
                            color: Color(0xffFF7A00),
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    /// ================= ADD TO CART =================
                    ElevatedButton(
                      onPressed: addToCartProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 60),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= QTY BUTTON =================
  Widget qtyButton(IconData icon, VoidCallback onTap, {bool isAdd = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          color: isAdd ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isAdd ? Colors.white : Colors.black, size: 18),
      ),
    );
  }

  //icon btn widget(share,back)
  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  //section widget
  Widget _sectionCard({
    required String title,
    Widget? child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (trailing != null) trailing,
            ],
          ),
          if (child != null) ...[const SizedBox(height: 8), child],
        ],
      ),
    );
  }
}
