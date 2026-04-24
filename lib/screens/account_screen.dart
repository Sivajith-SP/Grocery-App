import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'my_details_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final options = [
      {
        "title": "Orders",
        "icon": "icons/Orders icon.svg",
        "onTap": () {
          Navigator.pushNamed(context, '/orderDetails');
        },
      },
      {
        "title": "My Details",
        "icon": "icons/My Details icon.svg",
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyDetailsScreen()),
          );
        },
      },
      {
        "title": "Delivery Address",
        "icon": "icons/Delicery address.svg",
        "onTap": () {
          Navigator.pushNamed(context, '/addressScreen');
        },
      },
      {
        "title": "Payment Methods",
        "icon": "icons/Vector icon.svg",
        "onTap": () {},
      },
      {"title": "Notifications", "icon": "icons/Bell icon.svg", "onTap": () {}},
      {"title": "Help", "icon": "icons/help icon.svg", "onTap": () {}},
      {"title": "About", "icon": "icons/about icon.svg", "onTap": () {}},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Profile Card
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary,),);
                }

                var data = snapshot.data!.data() as Map<String, dynamic>;

                return Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(Icons.person, color: Colors.grey, size: 30),
                      ),
                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  data['username'] ?? "No Name",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                // const SizedBox(width: 8),
                                // SvgPicture.asset(
                                //   "icons/edit.svg",
                                //   width: 16,
                                //   color: AppColors.primary,
                                // ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['email'] ?? "No Email",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Grouped Options Container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      return GroupedTile(
                        title: options[index]['title'] as String,
                        icon: options[index]['icon'] as String,
                        onTap: options[index]['onTap'] as VoidCallback,
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 60, right: 20),
                        child: Divider(
                          thickness: 0.6,
                          color: Colors.grey.shade300,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          "Are you sure you want to logout?",
                          style: TextStyle(fontSize: 20),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),

                          //  LOGOUT BUTTON
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.of(context, rootNavigator: true).pop();

                              await FirebaseAuth.instance.signOut();
                              // final prefs = await SharedPreferences.getInstance();
                              // await prefs.setBool("isLoggedIn", false);

                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/logIn',
                                (route) => false,
                              );
                            },
                            child: const Text("Logout"),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Container(
                  height: 55,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "icons/logout.svg",
                        width: 18,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Grouped Tile
class GroupedTile extends StatefulWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const GroupedTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  State<GroupedTile> createState() => _GroupedTileState();
}

class _GroupedTileState extends State<GroupedTile> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => isPressed = true);
      },
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),

      child: Container(
        decoration: BoxDecoration(
          color: isPressed
              ? const Color(0xffFFFFFF) // Light orange highlight
              : Colors.transparent,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: SvgPicture.asset(widget.icon, width: 20),
          title: Text(
            widget.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isPressed
                  ? const Color(0xffFF7A00)
                  : const Color(0xff1E1E1E),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isPressed ? const Color(0xffFF7A00) : Colors.grey,
          ),
        ),
      ),
    );
  }
}
