import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/models/product_model.dart';
import 'package:grocery_app/screens/search_screen.dart';
import 'package:grocery_app/services/product_services.dart';
import 'package:grocery_app/widgets/banners.dart';
import 'package:grocery_app/widgets/product_card.dart';
import 'package:grocery_app/models/address_model.dart';
import 'package:shimmer/shimmer.dart';

import '../services/address_services.dart';

class GroceryHomeScreen extends StatefulWidget {
  const GroceryHomeScreen({super.key});

  @override
  State<GroceryHomeScreen> createState() => _GroceryHomeScreenState();
}

class _GroceryHomeScreenState extends State<GroceryHomeScreen> {
  AddressModel? selectedAddress;
  final AddressService _addressService = AddressService();
  final ProductServices _productService = ProductServices();

  bool isLoading = false;

  // Exclusive products
  List<Product> exclusive = [];

  //Best Selling
  List<Product> bestSelling = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchSelectedAddress();
  }

  void fetchSelectedAddress() async {
    final data = await _addressService.getSelectedAddress();

    if (data != null) {
      setState(() {
        selectedAddress = AddressModel.fromMap(data, "");
      });
    }
  }

  void fetchProducts() async {
    setState(() {
      isLoading = true;
    });

    final ex = await _productService.getExclusiveProduct();
    final bs = await _productService.getBestSellingProduct();

    setState(() {
      exclusive = ex;
      bestSelling = bs;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const HomeShimmer()
            : SingleChildScrollView(
                scrollDirection: .vertical,
                child: Column(
                  mainAxisAlignment: .start,
                  children: [
                    SizedBox(height: 20),
                    //logo+address+notification
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          //  LOGO
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "images/urban_basket_icon_logo.svg",
                                width: 20,
                                height: 20,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.primary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 10),
                              SvgPicture.asset(
                                "images/urban_basket_txt_logo.svg",
                                width: 60,
                                height: 15,
                                colorFilter: ColorFilter.mode(
                                  AppColors.accent.withOpacity(0.8),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          //  (Location + Notification)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LOCATION
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Deliver to:",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            selectedAddress != null
                                                ? "${selectedAddress!.pincode}, ${selectedAddress!.city}"
                                                : "Select Address",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // NOTIFICATION
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade100,
                                ),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.notifications_none),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    //search box
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: GestureDetector(
                        onTap: () async {
                          final productService = ProductServices();

                          //  fetch all products
                          final allProducts = await productService
                              .getAllProducts();

                          // navigate to search screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SearchScreen(products: allProducts),
                            ),
                          );
                        },
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.search, color: Colors.grey),
                              SizedBox(width: 10),
                              Text(
                                "Search Store",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    //carousel images
                    Center(child: BannerCarousel()),
                    SizedBox(height: 20),
                    //Exclusive products
                    ProductSection(
                      context: context,
                      headerTitle: "Exclusive Offers",
                      products: exclusive,
                    ),
                    SizedBox(height: 20),
                    //Best Selling
                    ProductSection(
                      context: context,
                      headerTitle: "Best Selling",
                      products: bestSelling,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }
}

//Product Detailed Screen

class SecondScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final double price;
  final String imgUrl;
  final String description;
  final String details;

  const SecondScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.imgUrl,
    required this.description,
    required this.details,
  });

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
  Widget build(BuildContext context) {
    //screen size
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                //image
                SizedBox(
                  height: screenHeight * 0.38,
                  width: screenWidth,
                  child: Image.network(widget.imgUrl, fit: .cover),
                ),
                //back button
                Positioned(
                  left: 20,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios),
                  ),
                ),
                //share button
                Positioned(
                  right: 20,
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.ios_share),
                  ),
                ),
              ],
            ),
            //text,price,favourites
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        widget.description,
                        style: TextStyle(fontSize: 24, fontWeight: .bold),
                      ),
                      Text(
                        widget.subtitle,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.favorite_outline,
                      size: 24,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            //quantity selector and price
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 30),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Container(
                    //item counter
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        //minus button
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.remove,
                            size: 28,
                            color: Colors.grey,
                          ),
                        ),
                        //item counter
                        Container(
                          alignment: .center,
                          padding: .only(
                            left: 20,
                            right: 20,
                            top: 10,
                            bottom: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: .circular(15),
                            border: .all(color: Colors.grey, width: 1),
                          ),
                          child: Text(
                            "1",
                            style: TextStyle(fontSize: 18, fontWeight: .bold),
                          ),
                        ),
                        //add button
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.add, size: 28, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  //price
                  Text(
                    '\$ ${widget.price.toString()}',
                    style: TextStyle(fontSize: 24, fontWeight: .bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            //Divider
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Divider(color: Colors.grey.shade300),
            ),
            //product detail,Nutritions & Review
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  //text
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text(
                        "Product Details",
                        style: TextStyle(fontSize: 16, fontWeight: .bold),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.keyboard_arrow_down_outlined,
                          fontWeight: .bold,
                        ),
                      ),
                    ],
                  ),
                  //product details
                  Text(
                    widget.details,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 10),
                  //Divider
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Colors.grey.shade300),
                  ),
                  SizedBox(height: 5),
                  //Nutrition
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text(
                        "Nutrtions",
                        style: TextStyle(fontSize: 16, fontWeight: .bold),
                      ),
                      //100gr and arrow btn
                      Row(
                        children: [
                          //100gr
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: .circular(5),
                            ),
                            padding: .all(3),
                            child: Text(
                              "100gr",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          SizedBox(width: 4),
                          //arrow btn
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                  //Divider
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Divider(color: Colors.grey.shade300),
                  ),
                  //Review
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text(
                        "Review",
                        style: TextStyle(fontSize: 16, fontWeight: .bold),
                      ),
                      //ratings and arrow btn
                      Row(
                        children: [
                          //rating
                          Container(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.deepOrange,
                                  size: 22,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.deepOrange,
                                  size: 22,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.deepOrange,
                                  size: 22,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.deepOrange,
                                  size: 22,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.deepOrange,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 4),
                          //arrow btn
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  //add to basket button
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(380, 60),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(15),
                      ),
                    ),
                    child: Text(
                      "Add to Basket",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//product section widget
Widget ProductSection({
  required BuildContext context,
  required String headerTitle,
  required List<Product> products,
}) {
  return Padding(
    padding: const EdgeInsets.only(left: 15, right: 15),
    child: Column(
      crossAxisAlignment: .center,
      children: [
        //Header
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 20),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  headerTitle,
                  style: TextStyle(fontSize: 24, fontWeight: .w600),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen(products: products)));
                  },
                  child: Text(
                    "see all",
                    style: TextStyle(fontSize: 16, color: Color(0xffFF7A00)),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 15),
        //cards
        SizedBox(
          height: 260,
          child: ListView.builder(
            itemCount: products.length,
            scrollDirection: .horizontal,
            padding: .only(left: 6, right: 6),
            itemBuilder: (context, index) =>
                ProductCard(product: products[index]),
          ),
        ),
      ],
    ),
  );
}

//shimmer-home
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: .start,
        children: [
          const SizedBox(height: 20),

          // LOGO
          shimmerBox(height: 15, width: 100, radius: 10),

          const SizedBox(height: 20),

          // LOCATION
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Align(alignment:.centerLeft,child: shimmerBox(height: 14, width: 150)),
          ),

          const SizedBox(height: 20),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: shimmerBox(height: 50, width: double.infinity, radius: 16),
          ),

          const SizedBox(height: 20),

          // BANNER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: shimmerBox(height: 140, width: double.infinity, radius: 16),
          ),

          const SizedBox(height: 25),

          // SECTION 1
          sectionShimmer(),

          const SizedBox(height: 25),

          // SECTION 2
          sectionShimmer(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// SECTION (TITLE + HORIZONTAL CARDS)
  Widget sectionShimmer() {
    return Column(
      children: [
        // TITLE ROW
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              shimmerBox(height: 18, width: 140),
              shimmerBox(height: 14, width: 60),
            ],
          ),
        ),

        const SizedBox(height: 15),

        // PRODUCT LIST
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, __) => shimmerCard(),
          ),
        ),
      ],
    );
  }

  /// PRODUCT CARD SHIMMER
  Widget shimmerCard() {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          Expanded(child: shimmerBox(width: double.infinity, radius: 12)),

          const SizedBox(height: 10),

          // TITLE
          shimmerBox(height: 14, width: double.infinity),

          const SizedBox(height: 6),

          // SUBTITLE
          shimmerBox(height: 12, width: 100),

          const SizedBox(height: 10),

          // PRICE + BTN
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              shimmerBox(height: 14, width: 40),
              shimmerBox(height: 28, width: 28, radius: 8),
            ],
          ),
        ],
      ),
    );
  }

  /// COMMON SHIMMER BOX
  Widget shimmerBox({
    double height = 12,
    double width = double.infinity,
    double radius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
