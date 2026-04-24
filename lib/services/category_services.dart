import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:grocery_app/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //add category

  Future<bool> addCategory(CategoryModel category) async {
    try {
      await _firestore.collection('categories').add(category.toMap());

      return true;
    } catch (e) {
      print("Error adding category:$e");
      return false;
    }
  }

  //get all categories

  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();

      return snapshot.docs.map((doc) {
        return CategoryModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching category:$e");
      return [];
    }
  }
}
