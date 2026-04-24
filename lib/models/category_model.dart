
class CategoryModel {
  final String id;
  final String name;
  final String image;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
  });

  //convert firestore to model
  factory CategoryModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CategoryModel(
      id: documentId,
      name: data["name"] ?? "",
      image: data["image"] ?? "",
    );
  }

  //convert model to firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
    };
  }
}
