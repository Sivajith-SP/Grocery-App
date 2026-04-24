import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/favourite_model.dart';
import '../provider/favourites_provider.dart';
import '../services/favourite_services.dart';
import '../services/cart_services.dart';
import '../models/cart_model.dart';
import '../widgets/favourites_shimmer.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  bool isAddingAll = false;
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    checkInternet();
  }

  Future<void> checkInternet() async {
    final result = await Connectivity().checkConnectivity();

    setState(() {
      hasInternet = result != ConnectivityResult.none;
    });

    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        hasInternet = result != ConnectivityResult.none;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = Provider.of<FavouriteProvider>(context, listen: false);
    final favService = FavouriteServices();
    // final cartService = CartServices();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Favourites",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xff1E1E1E),
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: favService.getFavourites(),
        builder: (context, snapshot) {
          if (!hasInternet) {
            return const Center(child: Text("No Internet Connection"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const FavouriteShimmer();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No favourites yet"));
          }

          if (snapshot.hasError) {
            return const FavouriteShimmer(); // no internet
          }

          final favourites = snapshot.data!.docs.map((doc) {
            return FavouriteModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          return Stack(
            children: [
              /// LIST
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: favourites.length,

                    itemBuilder: (context, index) {
                      final item = favourites[index];

                      return GroupedProductTile(
                        url: item.image,
                        text: item.title,
                        subtext: item.subtitle,
                        price: "₹${item.price}",

                        //  MOVE SINGLE ITEM
                        onMoveToCart: () async {
                          await favProvider.moveToCart(item);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Moved to cart")),
                          );
                        },

                        onDelete: () {
                          favProvider.removeFavourite(item.id!);
                        },
                      );
                    },

                    separatorBuilder: (_, __) => Padding(
                      padding: const EdgeInsets.only(left: 90, right: 20),
                      child: Divider(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),

              // ADD ALL TO CART
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  onPressed: isAddingAll
                      ? null
                      : () async {
                          // for (var item in favourites) {
                          //   await cartService.addToCartProduct(
                          //     CartModel(
                          //       productId: item.productId,
                          //       title: item.title,
                          //       subtitle: item.subtitle,
                          //       image: item.image,
                          //       price: item.price,
                          //       quantity: 1,
                          //     ),
                          //   );
                          // }

                          if (favourites.isEmpty) return;

                          setState(() => isAddingAll = true);

                          await favProvider.addAllToCart(favourites);

                          setState(
                            () => isAddingAll = false,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Added ${favourites.length} items to cart",
                                style: TextStyle(color: AppColors.white),
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: isAddingAll
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Add all to cart",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(Icons.shopping_cart),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class GroupedProductTile extends StatefulWidget {
  final String url;
  final String text;
  final String subtext;
  final String price;
  final VoidCallback onDelete;
  final VoidCallback onMoveToCart;

  const GroupedProductTile({
    super.key,
    required this.url,
    required this.text,
    required this.subtext,
    required this.price,
    required this.onDelete,
    required this.onMoveToCart,
  });

  @override
  State<GroupedProductTile> createState() => _GroupedProductTileState();
}

class _GroupedProductTileState extends State<GroupedProductTile> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => isPressed = true);
      },
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),

      child: Container(
        color: isPressed ? const Color(0xffFFFFFF) : Colors.transparent,

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.url,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,

                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 60,
                        width: 60,
                        color: Colors.white,
                      ),
                    );
                  },

                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.text,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtext,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // PRICE + DELETE
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //  PRICE
                  Text(
                    widget.price,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      //  MOVE TO CART
                      GestureDetector(
                        onTap: widget.onMoveToCart,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 18,
                            color: Colors.green,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      //  DELETE
                      GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
