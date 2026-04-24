class FavouriteModel {
  String? id;
  String userId;
  String productId;
  String title;
  String subtitle;
  String image;
  double price;

  FavouriteModel({
    this.id,
    required this.userId,
    required this.productId,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.price,
  });

  // FROM MAP
  factory FavouriteModel.fromMap(Map<String, dynamic> map, String docId) {
    return FavouriteModel(
      id: docId,
      userId: map['userId'],
      productId: map['productId'],
      title: map['title'],
      subtitle: map['subtitle'],
      image: map['image'],
      price: (map['price'] as num).toDouble(),
    );
  }

  // TO MAP
  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "productId": productId,
      "title": title,
      "subtitle": subtitle,
      "image": image,
      "price": price,
    };
  }
}