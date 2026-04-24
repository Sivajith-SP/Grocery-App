import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final String image;
  final String categoryId;
  final String details;
  final String description;

  final bool isExclusive;
  final bool isBestSelling;

  final Timestamp? createdAt;

  Product({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.image,
    required this.categoryId,
    required this.details,
    required this.description,
    required this.isExclusive,
    required this.isBestSelling,
    this.createdAt,
  });

  //firestore -> model

  factory Product.fromMap(Map<String, dynamic> data, String documentId){
    return Product(
        id: documentId,
        title: data["title"]??'',
        subtitle:  data["subtitle"]??'',
        price:  (data["price"]??0).toDouble(),
        image:  data["image"]??'',
        categoryId: data["categoryId"]??'',
        details:  data["details"]??'',
        description:  data["description"]??'',
        isExclusive:  data["isExclusive"]??false,
        isBestSelling:  data["isBestSelling"]??false,
      createdAt: data["createdAt"],
    );
  }

  //model -> firestore
Map<String,dynamic> toMap(){
    return {
      'title':title,
      'subtitle':subtitle,
      'price':price,
      'image':image,
      'categoryId':categoryId,
      'details':details,
      'description':description,
      'isExclusive':isExclusive,
      'isBestSelling':isBestSelling,
      'createdAt':createdAt??FieldValue.serverTimestamp(),

    };
}

}