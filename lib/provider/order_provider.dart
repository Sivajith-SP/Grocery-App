import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../services/order_services.dart';

class OrderProvider with ChangeNotifier {
  final OrderServices _orderService = OrderServices();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> placeOrder(
      List<CartModel> cartItems,
      double total,
      Map<String, dynamic> address,
      ) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _orderService.placeOrder(cartItems, total, address);

      _isLoading = false;
      notifyListeners();

      return true; // success
    } catch (e) {
      debugPrint("Order Error: $e");
      _isLoading = false;
      notifyListeners();
      return false; // fail
    }
  }
}