class AddressModel {
  String? id;
  String name;
  String phone;
  String house;
  String area;
  String city;
  String pincode;
  String type;
  bool isSelected;

  AddressModel({
    this.id,
    required this.name,
    required this.phone,
    required this.house,
    required this.area,
    required this.city,
    required this.pincode,
    required this.type,
    this.isSelected = false,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map, String docId) {
    return AddressModel(
      id: docId,
      name: map['name'],
      phone: map['phone'],
      house: map['house'],
      area: map['area'],
      city: map['city'],
      pincode: map['pincode'],
      type: map['type'],
      isSelected: map['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "phone": phone,
      "house": house,
      "area": area,
      "city": city,
      "pincode": pincode,
      "type": type,
      "isSelected": isSelected,
    };
  }
}