import 'dart:convert';

CommentModel commentModelFromJson(String str) =>
    CommentModel.fromJson(json.decode(str));

String commentModelToJson(CommentModel data) => json.encode(data.toJson());

class CommentModel {
  int id;
  User user;
  String? comment;
  DateTime createdAt;
  dynamic replyTo;
  int product;

  CommentModel({
    required this.id,
    required this.user,
    this.comment,
    required this.createdAt,
    required this.replyTo,
    required this.product,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json["id"],
        user: User.fromJson(json["user"]),
        comment: json["comment"] as String?, // Cast to String?
        createdAt: DateTime.parse(json["created_at"]),
        replyTo: json["reply_to"],
        product: json["product"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user.toJson(),
        "comment": comment,
        "created_at": createdAt.toIso8601String(),
        "reply_to": replyTo,
        "product": product,
      };
}

class User {
  int id;
  String? username;
  String? typeTitle;
  dynamic img;
  String? phoneNumber;
  String? name;
  bool blok;
  dynamic address;
  dynamic rating;
  String? userStatusChanging;
  dynamic imgUrl;
  int productcount;
  int premiumcount;
  int viewcount;

  User({
    required this.id,
    this.username,
    this.typeTitle,
    required this.img,
    this.phoneNumber,
    this.name,
    required this.blok,
    this.address,
    this.rating,
    this.userStatusChanging,
    this.imgUrl,
    required this.productcount,
    required this.premiumcount,
    required this.viewcount,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"] as String?,
        typeTitle: json["type_title"] as String?,
        img: json["img"],
        phoneNumber: json["phone_number"] as String?,
        name: json["name"] as String?,
        blok: json["blok"],
        address: json["address"],
        rating: json["rating"]?.toString(),
        userStatusChanging: json["user_status_changing"] as String?,
        imgUrl: json["img_url"],
        productcount: json["productcount"],
        premiumcount: json["premiumcount"],
        viewcount: json["viewcount"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "type_title": typeTitle,
        "img": img,
        "phone_number": phoneNumber,
        "name": name,
        "blok": blok,
        "address": address,
        "rating": rating,
        "user_status_changing": userStatusChanging,
        "img_url": imgUrl,
        "productcount": productcount,
        "premiumcount": premiumcount,
        "viewcount": viewcount,
      };
}
