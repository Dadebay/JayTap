import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

CategoryResponse categoryResponseFromJson(String str) =>
    CategoryResponse.fromJson(json.decode(str));

class CategoryResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<CategoryModel> results;

  CategoryResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      CategoryResponse(
        count: json["count"],
        next: json["next"] ?? '',
        previous: json["previous"] ?? '',
        results: List<CategoryModel>.from(
            json["results"].map((x) => CategoryModel.fromJson(x))),
      );
}

class SubCategoryModel {
  final String titleTk;
  final String titleEn;
  final String titleRu;
  final String imgUrl;

  SubCategoryModel({
    required this.titleTk,
    required this.titleEn,
    required this.titleRu,
    required this.imgUrl,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) =>
      SubCategoryModel(
        titleTk: json["title_tk"] ?? '',
        titleEn: json["title_en"] ?? '',
        titleRu: json["title_ru"] ?? '',
        imgUrl: json["img_url"] ?? '',
      );
  String getLocalizedTitle(BuildContext context) {
    final locale = Get.locale?.languageCode ?? 'tr';
    switch (locale) {
      case 'en':
        return titleEn;
      case 'ru':
        return titleRu;
      case 'tr':
      default:
        return titleTk;
    }
  }
}

class CategoryModel {
  final int id;
  final String titleTk;
  final String titleEn;
  final String titleRu;
  final List<SubCategoryModel> subcategory;

  CategoryModel({
    required this.id,
    required this.titleTk,
    required this.titleEn,
    required this.titleRu,
    required this.subcategory,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    var subcategoryList = <SubCategoryModel>[];
    if (json['subcategory'] != null && json['subcategory'] is List) {
      subcategoryList = List<SubCategoryModel>.from(
        json["subcategory"].map((x) => SubCategoryModel.fromJson(x)),
      );
    }

    return CategoryModel(
      id: json["id"],
      titleTk: json["title_tk"],
      titleEn: json["title_en"],
      titleRu: json["title_ru"],
      subcategory: subcategoryList,
    );
  }

  String getLocalizedTitle(BuildContext context) {
    final locale = Get.locale?.languageCode ?? 'tr';
    switch (locale) {
      case 'en':
        return titleEn;
      case 'ru':
        return titleRu;
      case 'tr':
      default:
        return titleTk;
    }
  }
}
