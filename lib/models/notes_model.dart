
import 'package:cloud_firestore/cloud_firestore.dart';

class Notes {

  final String title; //banner text

  Notes({required this.title});

  //factory constructor             //one document from firestore
  factory Notes.fromFirestore(Map<String,dynamic> map){

    //return object
    return Notes(
      title: map['title'] ?? '',
    );
  }

  //converts dart object to firestore format
  Map<String,dynamic> toMap(){
    return {
      'title' : title,
    };
  }


}
