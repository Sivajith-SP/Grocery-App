import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_model.dart';

class OrderServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> placeOrder(
      List<CartModel> cartItems,
      double total,
      Map<String, dynamic> address,
      ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    List<Map<String, dynamic>> items = cartItems.map((item) {
      return {
        "productId": item.id,
        "title": item.title,
        "price": item.price,
        "quantity": item.quantity,
        "image": item.image,
      };
    }).toList();

    await _firestore.collection('orders').add({
      "userId": user.uid,
      "items": items,
      "totalAmount": total,
      "status": "pending",
      "address": address,
      "createdAt": FieldValue.serverTimestamp(),
    });

    // CLEAR CART
    final snapshot = await _firestore
        .collection('cartItems')
        .where('userId', isEqualTo: user.uid)
        .get();

    WriteBatch batch = _firestore.batch();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}