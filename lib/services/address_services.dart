import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address_model.dart';

class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  //  Add Address
  Future<void> addAddress(AddressModel address) async {
    final collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses');

    final snapshot = await collection.get();

    // First address auto selected
    if (snapshot.docs.isEmpty) {
      address.isSelected = true;
    }

    await collection.add(address.toMap());
  }

  //  Get Addresses
  Stream<QuerySnapshot> getAddresses() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .snapshots();
  }

  //  Delete
  Future<void> deleteAddress(String id) async {
    final collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses');

    await collection.doc(id).delete();

    final snapshot = await collection.get();

    if (snapshot.docs.isNotEmpty) {
      await selectAddress(snapshot.docs.first.id);
    }
  }

  // ✏ Update
  Future<void> updateAddress(String id, AddressModel address) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(id)
        .update(address.toMap());
  }

  //  SELECT ADDRESS
  Future<void> selectAddress(String addressId) async {
    final collection = _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses');

    final snapshot = await collection.get();

    final batch = _firestore.batch();

    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {
        'isSelected': doc.id == addressId
      });
    }

    await batch.commit();
  }

  // ✅ GET SELECTED ADDRESS (FOR ORDER)
  Future<Map<String, dynamic>?> getSelectedAddress() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .where('isSelected', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }

    return null;
  }
}