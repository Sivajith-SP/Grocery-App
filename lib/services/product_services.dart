
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/models/product_model.dart';

class ProductServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //add products

  Future<bool> addProduct(Product product) async {
    try {
      await _firestore.collection('products').add(product.toMap());

      return true;
    } catch (e) {
      print("Error adding product:$e");
      return false;
    }
  }

  //get all products

  Future<List<Product>> getProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      print(snapshot);

      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e,stackTrace) {
      print("Error fetching products:$e");
      print("Stack Trace:$stackTrace");
      return [];
    }
  }

  //update products

  Future<bool> updateProduct(Product product) async {
    try{
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toMap());

      return true;
    } catch(e,stackTrace){
      print("Update product error:$e");
      print("Stack Trace:$stackTrace");
      return false;
    }
  }

  //delete products

  Future<bool> deleteProduct(String productId) async {
    try{
      await _firestore.collection('products').doc(productId).delete();
      return true;
    } catch(e,stackTrace){
      print("Delete  product error:$e");
      print("Stack Trace:$stackTrace");
      return false;
    }
  }

  //exclusive products

  Future<List<Product>> getExclusiveProduct() async {
    final snapshot = await _firestore
        .collection('products')
        .where('isExclusive',isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Product.fromMap(doc.data(),doc.id))
        .toList();
  }

  //best selling

  Future<List<Product>> getBestSellingProduct() async {
    final snapshot = await _firestore
        .collection('products')
        .where('isBestSelling',isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => Product.fromMap(doc.data(),doc.id))
        .toList();
  }

  //get products by category
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching category products: $e");
      return [];
    }
  }

  //  SEARCH PRODUCTS
  Future<List<Product>> getAllProducts() async {
    return await getProducts(); // reuse existing method
  }



}