// lib/modules/home/models/banner_model.dart

import 'dart:convert';

BannerResponse bannerResponseFromJson(String str) =>
    BannerResponse.fromJson(json.decode(str));

class BannerResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<BannerModel> results;

  BannerResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) => BannerResponse(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        results: List<BannerModel>.from(
            json["results"].map((x) => BannerModel.fromJson(x))),
      );
}

class BannerModel {
  final int id;
  final String img;
  final String? link;
  final String? description;
  final String? catID;
  final String? productID;
  final int order;
  final int perPage;

  BannerModel(
      {required this.id,
      required this.img,
      required this.link,
      required this.order,
      required this.perPage,
      required this.catID,
      required this.description,
      required this.productID});

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json["id"],
        img: json["img_url"],
        link: json["link"] ?? '',
        order: json["order"],
        perPage: json["per_page"],
        catID: json["cat_id"].toString(),
        description: json["description"].toString(),
        productID: json["product_id"].toString(),
      );
}
