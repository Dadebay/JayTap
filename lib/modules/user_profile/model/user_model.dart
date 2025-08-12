// lib/modules/user_profile/models/user_model.dart

class UserModel {
  final int id;
  final String username;
  final String typeTitle;
  final String? img;
  final String name;
  final bool blok;
  final String rating;
  final String userStatusChanging;
  final String productCount;
  final String viewCount;
  final String premiumCount;

  UserModel({
    required this.id,
    required this.username,
    required this.typeTitle,
    this.img,
    required this.name,
    required this.blok,
    required this.rating,
    required this.userStatusChanging,
    required this.productCount,
    required this.viewCount,
    required this.premiumCount,
  });

  // JSON verisinden UserModel nesnesi oluşturan factory constructor
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      typeTitle: json['type_title'] as String,
      img: json['img_url'] as String?,
      name: json['name'] as String,
      blok: json['blok'] as bool,
      rating: json['rating'].toString(),
      userStatusChanging: json['user_status_changing'].toString(),
      productCount: json['productcount'].toString(),
      viewCount: json['viewcount'].toString() ?? '0',
      premiumCount: json['premiumcount'].toString() ?? '0',
    );
  }
}
