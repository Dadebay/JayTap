import 'dart:convert';

CommentModel commentModelFromJson(String str) => CommentModel.fromJson(json.decode(str));

String commentModelToJson(CommentModel data) => json.encode(data.toJson());

class CommentModel {
    int id;
    User user;
    String comment;
    DateTime createdAt;
    dynamic replyTo;
    int product;

    CommentModel({
        required this.id,
        required this.user,
        required this.comment,
        required this.createdAt,
        required this.replyTo,
        required this.product,
    });

    factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json["id"],
        user: User.fromJson(json["user"]),
        comment: json["comment"],
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
    String username;
    String typeTitle;
    dynamic img;
    String phoneNumber;
    String name;
    bool blok;
    dynamic address;
    String rating;
    String userStatusChanging;
    dynamic imgUrl;
    int productcount;
    int premiumcount;
    int viewcount;

    User({
        required this.id,
        required this.username,
        required this.typeTitle,
        required this.img,
        required this.phoneNumber,
        required this.name,
        required this.blok,
        required this.address,
        required this.rating,
        required this.userStatusChanging,
        required this.imgUrl,
        required this.productcount,
        required this.premiumcount,
        required this.viewcount,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        username: json["username"],
        typeTitle: json["type_title"],
        img: json["img"],
        phoneNumber: json["phone_number"],
        name: json["name"],
        blok: json["blok"],
        address: json["address"],
        rating: json["rating"],
        userStatusChanging: json["user_status_changing"],
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
