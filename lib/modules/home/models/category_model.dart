// lib/modules/home/models/category_model.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

CategoryResponse categoryResponseFromJson(String str) => CategoryResponse.fromJson(json.decode(str));

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

  factory CategoryResponse.fromJson(Map<String, dynamic> json) => CategoryResponse(
        count: json["count"],
        next: json["next"] ?? '',
        previous: json["previous"] ?? '',
        results: List<CategoryModel>.from(json["results"].map((x) => CategoryModel.fromJson(x))),
      );
}

class CategoryModel {
  final int id;
  final String titleTk;
  final String titleEn;
  final String titleRu;
  final String img;
  final int quantity;

  CategoryModel({
    required this.id,
    required this.titleTk,
    required this.titleEn,
    required this.titleRu,
    required this.img,
    required this.quantity,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json["id"],
        titleTk: json["title_tk"],
        titleEn: json["title_en"],
        titleRu: json["title_ru"],
        img: json["img_url"],
        quantity: json["quantity"],
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
