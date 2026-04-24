import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_services.dart';

class CategoryProvider with ChangeNotifier{

  List<CategoryModel> categories = [];

  final CategoryService _categoryService = CategoryService();


  Future<void> fetchCategory() async {
    final data = await _categoryService.getCategories();
    print(data);
    categories = data;
    print(categories);
    notifyListeners();
  }
}