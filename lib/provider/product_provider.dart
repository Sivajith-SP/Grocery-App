import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_services.dart';

class ProductProvider with ChangeNotifier {
  final ProductServices _productService = ProductServices();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> addProduct(Product product) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await _productService.addProduct(product);

      _isLoading = false;
      notifyListeners();

      return success;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}