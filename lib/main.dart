import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grocery_app/core/theme/app_colors.dart';
import 'package:grocery_app/core/theme/app_theme.dart';
import 'package:grocery_app/provider/banner_provider.dart';
import 'package:grocery_app/provider/cart_provider.dart';
import 'package:grocery_app/provider/category_provider.dart';
import 'package:grocery_app/provider/favourites_provider.dart';
import 'package:grocery_app/provider/order_provider.dart';
import 'package:grocery_app/provider/product_provider.dart';
import 'package:grocery_app/screens/Admin/add_banner_screen.dart';
import 'package:grocery_app/screens/Admin/add_category.dart';
import 'package:grocery_app/screens/Admin/add_product_screen.dart';
import 'package:grocery_app/screens/Admin/admin__product_list_screen.dart';
import 'package:grocery_app/screens/Admin/admin_customers_screen.dart';
import 'package:grocery_app/screens/Admin/admin_homescreen.dart';
import 'package:grocery_app/screens/Admin/admin_orders_screen.dart';
import 'package:grocery_app/screens/account_screen.dart';
import 'package:grocery_app/screens/address_screen.dart';
import 'package:grocery_app/screens/explore_screen.dart';
import 'package:grocery_app/screens/forgot_password_screen.dart';
import 'package:grocery_app/screens/home_screen.dart';
import 'package:grocery_app/screens/login_screen.dart';
import 'package:grocery_app/screens/order_success_screen.dart';
import 'package:grocery_app/screens/orders_account_screen.dart';
import 'package:grocery_app/screens/signup_screen.dart';
import 'package:grocery_app/screens/splash_screen.dart';
import 'package:grocery_app/screens/cart.dart';
import 'package:grocery_app/screens/favourites_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background message received");
  print("title:${message.notification?.title}");
  print("body:${message.notification?.body}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName:".env");

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
    ),
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false
  );

  print("Permission status:${settings.authorizationStatus}");

  String? fcmToken = await FirebaseMessaging.instance.getToken();
  print("FCm token:$fcmToken");

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => BannerProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => CategoryProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => CartProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => OrderProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => FavouriteProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => ProductProvider(),
            ),
          ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              initialRoute: "/",
              routes: {
                "/": (context) => SplashScreen(),
                '/logIn': (context) => LogInScreen(),
                '/signUp': (context) => SignupScreen(),
                '/home': (context) => MainLayout(),
                // '/mobileNumberScreen':(context) => MobileNumberScreen(),
                // '/verificationScreen':(context) => VerificationScreen(),
                // '/locationScreen':(context)=> LocationScreen(),
                '/adminhome': (context) => AdminHomescreen(),
                '/addBanner': (context) => AddBannerScreen(),
                '/addCategory': (context) => AddCategoryScreen(),
                '/addProduct': (context) => AddProductScreen(),
                '/productList': (context) => AdminProductListScreen(),
                '/orders': (context) => AdminOrdersScreen(),
                '/customers': (context) => AdminCustomersScreen(),
                '/orderSuccess': (context) => OrderSuccessScreen(),
                '/orderDetails': (context) => UserOrdersScreen(),
                '/addressScreen': (context) => AddressScreen(),
                '/addAddress': (context) => AddAddressScreen(),
                '/forgotPassword': (context) =>  ForgotPasswordScreen(),
                '/resetConfirmation': (context) => ResetConfirmationScreen(),
              },
            ),
        );
      },
    ),
  );
}

// void main(){
//   runApp(
//     MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: CartPage(),
//     )
//   );
// }

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  final List<Widget> _screen = const [
    GroceryHomeScreen(),
    ExploreScreen(),
    CartPage(),
    FavouritesScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null && mounted) {
        _showNotification(
          message.notification!.title ?? '',
          message.notification!.body ?? '',

        );
      }
    });
  }

  void _showNotification(String title, String body) {
    showDialog(context: context, builder: (context) =>
        AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Ok")),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screen[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,

          backgroundColor: Color(0xffF3F4F6),
          elevation: 0,

          selectedItemColor: const Color(0xffFF7A00),
          //  primary
          unselectedItemColor: Colors.grey.shade500,

          showSelectedLabels: false,
          showUnselectedLabels: false,

          items: [
            //  SHOP
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "icons/shop.svg",
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                "icons/shop.svg",
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              label: "Shop",
            ),

            // EXPLORE
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "icons/explore.svg",
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                "icons/explore.svg",
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              label: "Explore",
            ),

            //  CART
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "icons/cart.svg",
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                "icons/cart.svg",
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              label: "Cart",
            ),

            // FAVORITE
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border),
              activeIcon: const Icon(Icons.favorite, color: AppColors.primary),
              label: "Favourite",
            ),

            // 👤 ACCOUNT
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "icons/account.svg",
                colorFilter: const ColorFilter.mode(
                  Colors.grey,
                  BlendMode.srcIn,
                ),
              ),
              activeIcon: SvgPicture.asset(
                "icons/account.svg",
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              label: "Account",
            ),
          ],
        ),
      ),
    );
  }
}
