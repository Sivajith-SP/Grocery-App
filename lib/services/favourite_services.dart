import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/favourite_model.dart';

class FavouriteServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get favRef => _firestore.collection('favourites');

  // CHECK IF PRODUCT IS FAVOURITE
  Future<bool> isFavourite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return false;

    final snapshot = await favRef
        .where('productId', isEqualTo: productId)
        .where('userId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // TOGGLE FAVOURITE
  Future<void> toggleFavourite(FavouriteModel fav) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await favRef
        .where('productId', isEqualTo: fav.productId)
        .where('userId', isEqualTo: user.uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await favRef.doc(snapshot.docs.first.id).delete();
    } else {
      await favRef.add(fav.toMap());
    }
  }

  // STREAM
  Stream<QuerySnapshot> getFavourites() {
    final user = FirebaseAuth.instance.currentUser;

    return favRef
        .where('userId', isEqualTo: user!.uid)
        .snapshots();
  }

  /// REMOVE
  Future<void> removeFavourite(String docId) async {
    await favRef.doc(docId).delete();
  }
}