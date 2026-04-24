import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/models/cart_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get cartRef => _firestore.collection('cartItems');

  //  ADD / UPDATE / DELETE
  Future<bool> addToCartProduct(CartModel cartItem) async {
    try {
      final user = FirebaseAuth.instance.currentUser; //

      if (user == null) return false;

      final snapshot = await cartRef
          .where('productId', isEqualTo: cartItem.productId)
          .where('userId', isEqualTo: user.uid) //
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        int currentQty = doc['quantity'];

        int newQty = currentQty + cartItem.quantity;

        if (newQty <= 0) {
          await cartRef.doc(doc.id).delete();
        } else {
          await cartRef.doc(doc.id).update({
            "quantity": newQty,
          });
        }
      } else {
        await cartRef.add({
          ...cartItem.toMap(),
          "userId": user.uid, //
        });
      }

      return true;
    } catch (e) {
      print("Cart error: $e");
      return false;
    }
  }

  //  GET CART (USER BASED)
  Future<List<CartModel>> getCartProducts() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return [];

    final snapshot = await cartRef
        .where('userId', isEqualTo: user.uid) //
        .get();

    return snapshot.docs.map((doc) {
      return CartModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  //  STREAM CART (USER BASED)
  Stream<QuerySnapshot> getCartItems() {
    final user = FirebaseAuth.instance.currentUser;

    return cartRef
        .where('userId', isEqualTo: user!.uid) //  FIX
        .snapshots();
  }
}