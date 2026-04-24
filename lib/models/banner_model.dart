import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String id; //document id from firestore
  final String image; //image url
  final String title; //banner text

  BannerModel({required this.id, required this.image, required this.title});

  //factory constructor             //one document from firestore
  factory BannerModel.fromFirestore(DocumentSnapshot doc){
    //extract data
    // doc.data() -> gets data from firestore document
    final data = doc.data() as Map<String,dynamic>;
    //return object
    return BannerModel(
        id: doc.id,
        image: data['image'] ?? '',
        title: data['title'] ?? '',
    );
  }

  //converts dart object to firestore format
  Map<String,dynamic> toMap(){
    return {
      'title' : title,
      'image' : image
    };
  }


}
