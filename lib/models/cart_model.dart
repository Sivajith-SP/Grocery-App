import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/models/product_model.dart';

class CartModel {
  final String? id;
  final String title;
  final String subtitle;
  final double price;
  final String image;
  final String productId;
   int quantity;
  final Timestamp? addedAt;

  CartModel({
    this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.image,
    required this.productId,
    required this.quantity,
    this.addedAt,
  });

  //firestore -> model
  factory CartModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CartModel(
      id: documentId,
      title: data["title"] ?? '',
      subtitle: data["subtitle"] ?? '',
      price: (data["price"] ?? 0).toDouble(),
      image: data["image"] ?? '',
      productId: data["productId"] ?? '',
      quantity: (data["quantity"] ?? 1) as int,
      addedAt: data["addedAt"],
    );
  }

  //model -> firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'image': image,
      'productId': productId,
      'quantity': quantity,
      'addedAt': addedAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory CartModel.fromProduct(Product product, int qty) {
    return CartModel(
      productId: product.id,
      title: product.title,
      subtitle: product.subtitle,
      price: product.price,
      image: product.image,
      quantity: qty,
      addedAt: Timestamp.now(),
    );
  }
}
