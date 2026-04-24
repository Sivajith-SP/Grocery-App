import 'package:flutter/material.dart';
import 'package:grocery_app/services/cart_services.dart';

class CartDemo extends StatefulWidget {
  const CartDemo({super.key});

  @override
  State<CartDemo> createState() => _CartDemoState();
}

class _CartDemoState extends State<CartDemo> {

  final CartServices _cartServices = CartServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("cart"),
      ),
      body: StreamBuilder(
          stream: _cartServices.getCartItems(), builder: (context, snapshot) {
        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        //no data
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text("Cart is Empty"),
          );
        }

        final cartItems = snapshot.data!.docs;

        return ListView.builder(
          itemCount: cartItems.length,
            itemBuilder: (context,index){
            var item = cartItems[index];

            return ListTile(
              title: Text(item['title']),
              subtitle: Text("${item['quantity'].toString()}"),
              trailing: Text("\$ ${item['price']}"),
            );
            }
        );
      }),
    );
  }
}
