import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/models/banner_model.dart';

class BannerServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


//CRUD read
  //get banners (one time fetch)

  Future<List<BannerModel>> getBanners() async {
    //fetch data
    final snapshot = await _firestore.collection('banners').get();

    return snapshot.docs
        .map((doc) => BannerModel.fromFirestore(doc))
        .toList();
  }
}