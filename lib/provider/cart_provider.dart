import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../services/cart_services.dart';

class CartProvider with ChangeNotifier {
  final CartServices _cartService = CartServices();

  Future<void> increaseQty(String id, int qty) async {
    await _cartService.cartRef.doc(id).update({
      "quantity": qty + 1,
    });
  }

  Future<void> decreaseQty(String id, int qty) async {
    if (qty <= 1) {
      await _cartService.cartRef.doc(id).delete();
    } else {
      await _cartService.cartRef.doc(id).update({
        "quantity": qty - 1,
      });
    }
  }

  Future<void> removeItem(String id) async {
    await _cartService.cartRef.doc(id).delete();
  }

  Future<void> addItem(CartModel item) async {
    await _cartService.cartRef.doc(item.id).set(item.toMap());
  }
}