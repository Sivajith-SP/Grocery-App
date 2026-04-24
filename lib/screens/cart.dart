import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../models/cart_model.dart';
import '../provider/cart_provider.dart';
import '../provider/order_provider.dart';
import '../services/cart_services.dart';
import '../services/order_services.dart';
import '../widgets/cart_shimmer.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartServices _cartService = CartServices();

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "My Cart",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xff1E1E1E),
          ),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: _cartService.getCartItems(),
        builder: (context, snapshot) {
          // NO INTERNET
          if (!hasInternet) {
            return const CartShimmer();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CartShimmer();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const EmptyCartWidget();
          }

          if (snapshot.hasError) {
            return const CartShimmer(); // no internet
          }

          final docs = snapshot.data!.docs;

          final cartItems = docs.map((doc) {
            return CartModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          double total = 0;
          for (var item in cartItems) {
            total += item.price * item.quantity;
          }

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final cartProvider = Provider.of<CartProvider>(
                        context,
                        listen: false,
                      );

                      return ProductItem(
                        item: {
                          "title": item.title,
                          "subtitle": item.subtitle,
                          "imgUrl": item.image,
                          "price": item.price,
                          "qty": item.quantity,
                        },
                        onAdd: () {
                          cartProvider.increaseQty(item.id!, item.quantity);
                        },
                        onRemove: () {
                          cartProvider.decreaseQty(item.id!, item.quantity);
                        },
                        onDelete: () async {
                          cartProvider.removeItem(item.id!);
                        },
                      );
                    },
                    separatorBuilder: (_, _) => Padding(
                      padding: const EdgeInsets.only(left: 90, right: 20),
                      child: Divider(
                        thickness: 0.6,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(25),
                        ),
                      ),
                      builder: (context) =>
                          CheckoutSheet(total: total, cartItems: cartItems),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Go to Checkout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffE86F00),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "\₹${total.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
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

// PRODUCT ITEM
class ProductItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  const ProductItem({
    super.key,
    required this.item,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  State<ProductItem> createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item["imgUrl"],
                  height: 60,
                  width: 60,
                  fit: BoxFit.scaleDown,

                  // SHIMMER LOADING
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

                  // ERROR (NO INTERNET)
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

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item["title"],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onDelete,
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item["subtitle"],
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            qtyButton(
                              Icons.remove,
                              widget.onRemove,
                              Colors.grey.shade200,
                              Colors.black,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(item["qty"].toString()),
                            ),
                            qtyButton(
                              Icons.add,
                              widget.onAdd,
                              AppColors.primary,
                              Colors.white,
                              isAdd: true,
                            ),
                          ],
                        ),
                        Text(
                          "\₹${(item["price"] * item["qty"]).toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget qtyButton(
  IconData icon,
  VoidCallback onTap,
  Color bgcolor,
  Color iconcolor, {
  bool isAdd = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgcolor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: iconcolor),
    ),
  );
}

//  CHECKOUT SHEET

class CheckoutSheet extends StatefulWidget {
  final double total;
  final List<CartModel> cartItems;

  const CheckoutSheet({
    super.key,
    required this.total,
    required this.cartItems,
  });

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  bool isLoading = false;
  bool isAddressLoading = true;
  Map<String, dynamic>? selectedAddress;

  @override
  void initState() {
    super.initState();
    loadSelectedAddress();
  }

  Future<void> loadSelectedAddress() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses');

    // Get SELECTED address
    final selectedSnapshot = await collection
        .where('isSelected', isEqualTo: true)
        .limit(1)
        .get();

    if (selectedSnapshot.docs.isNotEmpty) {
      selectedAddress = selectedSnapshot.docs.first.data();
    } else {
      //  fallback (first address)
      final fallback = await collection.limit(1).get();

      if (fallback.docs.isNotEmpty) {
        selectedAddress = fallback.docs.first.data();
      }
    }

    setState(() => isAddressLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TOP BAR
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Checkout",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // MAIN CARD
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CustomListTile(title: "Payment", value: "COD"),
                    //  DELIVERY
                    CustomListTile(
                      title: "Address",
                      value: isAddressLoading
                          ? "Loading..."
                          : selectedAddress == null
                          ? "No address"
                          : "${selectedAddress!['house']}, "
                                "${selectedAddress!['area']}, "
                                "${selectedAddress!['city']}",
                    ),

                    // CustomListTile(title: "Promo Code", value: "Pick discount"),
                    CustomListTile(
                      title: "Total Cost",
                      value: "\₹${widget.total.toStringAsFixed(2)}",
                      isBold: true,
                      showDivider: false,
                    ),

                    const SizedBox(height: 20),

                    // TERMS
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            text: "By placing an order you agree to our\n",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                            children: const [
                              TextSpan(
                                text: "Terms",
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(text: " And "),
                              TextSpan(
                                text: "Conditions",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //  PLACE ORDER BUTTON
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (selectedAddress == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select address"),
                            ),
                          );
                          return;
                        }

                        final orderProvider = Provider.of<OrderProvider>(
                          context,
                          listen: false,
                        );

                        setState(() => isLoading = true);

                        final navigator = Navigator.of(
                          context,
                          rootNavigator: true,
                        );

                        Navigator.pop(context);

                        //  small delay ensures latest selection
                        await Future.delayed(const Duration(milliseconds: 200));

                        final success = await orderProvider.placeOrder(
                          widget.cartItems,
                          widget.total,
                          selectedAddress!,
                        );

                        if (success) {
                          navigator.pushNamedAndRemoveUntil(
                            '/orderSuccess',
                            (route) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Order failed")),
                          );
                        }

                        setState(() => isLoading = false);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF7A00),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Place Order"),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;
  final bool showDivider;

  const CustomListTile({
    super.key,
    required this.title,
    required this.value,
    this.isBold = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          trailing: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xff1E1E1E),
            ),
          ),
        ),

        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Divider(thickness: 0.6, color: Colors.grey.shade300),
          ),
      ],
    );
  }
}

// EMPTY CART
class EmptyCartWidget extends StatelessWidget {
  const EmptyCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🛒 ICON
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: Color(0xffFF7A00),
              ),
            ),

            const SizedBox(height: 25),

            // TITLE
            const Text(
              "Your cart is empty",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            // SUBTITLE
            Text(
              "Looks like you haven’t added anything yet.\nStart shopping now!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 30),

            //  BUTTON
            ElevatedButton(
              onPressed: () {
                //  GO TO HOME SCREEN
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home', //  make sure your home route is '/home'
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF7A00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Back to Shopping",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
