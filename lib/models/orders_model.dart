import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String? id;
  String userId;
  List<Map<String, dynamic>> items;
  double totalAmount;
  String status;
  DateTime createdAt;
  Map<String, dynamic>? address; // ✅ SAFE NULLABLE

  OrderModel({
    this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.address,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate = DateTime.now();

    if (map['createdAt'] != null) {
      final value = map['createdAt'];

      if (value is Timestamp) {
        parsedDate = value.toDate();
      } else if (value is DateTime) {
        parsedDate = value;
      }
    }

    return OrderModel(
      id: docId,
      userId: map['userId'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      address: map['address'] != null
          ? Map<String, dynamic>.from(map['address'])
          : {},
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "items": items,
      "totalAmount": totalAmount,
      "status": status,
      "address": address,
      "createdAt": createdAt,
    };
  }
}