import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/core/theme/app_colors.dart';

class AdminHomescreen extends StatefulWidget {
  const AdminHomescreen({super.key});

  @override
  State<AdminHomescreen> createState() => _AdminHomescreenState();
}

class _AdminHomescreenState extends State<AdminHomescreen> {

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning ☀️";
    } else if (hour < 17) {
      return "Good Afternoon 🌤";
    } else {
      return "Good Evening 🌙";
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int totalOrders = 0;
  int totalUsers = 0;
  int totalProducts = 0;
  double totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      // ORDERS
      final ordersSnapshot =
      await _firestore.collection('orders').get();

      totalOrders = ordersSnapshot.docs.length;

      double revenue = 0;

      for (var doc in ordersSnapshot.docs) {
        revenue += (doc['totalAmount'] ?? 0).toDouble();
      }

      totalRevenue = revenue;

      // USERS
      final usersSnapshot =
      await _firestore.collection('users').get();

      totalUsers = usersSnapshot.docs.length;

      // PRODUCTS
      final productSnapshot =
      await _firestore.collection('products').get();

      totalProducts = productSnapshot.docs.length;

      setState(() {});
    } catch (e) {
      print("Dashboard error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        // title: const Text(
        //   "Admin Dashboard",
        //   style: TextStyle(
        //     fontWeight: FontWeight.w600,
        //     color: Color(0xff1E1E1E),
        //   ),
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text(
                      "Are you sure you want to logout?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text("Cancel",style: TextStyle(color: Colors.grey),),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text("Logout"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  );
                },
              );

              if (shouldLogout == true) {
                await FirebaseAuth.instance.signOut();

                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/logIn',
                        (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            //Greeting Msg
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getGreeting(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Welcome back, Admin 👨‍💼",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            SizedBox(height: 25,),

            // STATS ROW 1
            Row(
              children: [
                Expanded(child: statCard("Orders",  totalOrders.toString(), Icons.receipt_long)),
                const SizedBox(width: 12),
                Expanded(child: statCard("Customers", totalUsers.toString(), Icons.people)),
              ],
            ),

            const SizedBox(height: 12),

            // STATS ROW 2
            Row(
              children: [
                Expanded(child: statCard("Products", totalProducts.toString(), Icons.shopping_bag)),
                const SizedBox(width: 12),
                Expanded(child: statCard("Revenue",    "₹${totalRevenue.toStringAsFixed(0)}", Icons.currency_rupee)),
              ],
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E1E1E),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // GRID MENU
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,

              children: [
                dashboardCard(
                  context,
                  title: "Add Category",
                  icon: Icons.category_outlined,
                  onTap: () => Navigator.pushNamed(context, '/addCategory'),
                ),
                dashboardCard(
                  context,
                  title: "Add Product",
                  icon: Icons.shopping_bag_outlined,
                  onTap: () => Navigator.pushNamed(context, '/addProduct'),
                ),
                dashboardCard(
                  context,
                  title: "Add Banner",
                  icon: Icons.image_outlined,
                  onTap: () => Navigator.pushNamed(context, '/addBanner'),
                ),
                dashboardCard(
                  context,
                  title: "Orders",
                  icon: Icons.receipt_long_outlined,
                  onTap: () => Navigator.pushNamed(context, '/orders'),
                ),
                dashboardCard(
                  context,
                  title: "Product List",
                  icon: Icons.list_alt_outlined,
                  onTap: () => Navigator.pushNamed(context, '/productList'),
                ),
                dashboardCard(
                  context,
                  title: "Customers",
                  icon: Icons.people,
                  onTap: () => Navigator.pushNamed(context, '/customers'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // SMALL RECTANGLE STAT CARD
  Widget statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          // ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),

          const SizedBox(width: 12),

          // TEXT
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // GRID CARD (UNCHANGED)
  Widget dashboardCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}