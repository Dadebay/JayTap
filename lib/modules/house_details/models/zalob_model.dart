import 'package:get/get.dart';

// lib/modules/house_details/models/zaloba_model.dart

class ZalobaModel {
  final int id;
  final String titleTm;
  final String titleRu;
  final String titleEn;

  ZalobaModel({
    required this.id,
    required this.titleTm,
    required this.titleRu,
    required this.titleEn,
  });

  factory ZalobaModel.fromJson(Map<String, dynamic> json) {
    return ZalobaModel(
      id: json['id'],
      titleTm: json['title_tm'],
      titleRu: json['title_ru'],
      titleEn: json['title_en'],
    );
  }

  String get localizedName {
    final locale = Get.locale?.languageCode ?? 'tr';
    switch (locale) {
      case 'en':
        return titleEn;
      case 'ru':
        return titleRu;
      case 'tr':
        return titleTm;
      default:
        return titleTm;
    }
  }
}

// API'den gelen paginated response için bir yardımcı sınıf
class PaginatedZalobaResponse {
  final int count;
  final List<ZalobaModel> results;

  PaginatedZalobaResponse({required this.count, required this.results});

  factory PaginatedZalobaResponse.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List;
    List<ZalobaModel> zalobaList =
        list.map((i) => ZalobaModel.fromJson(i)).toList();
    return PaginatedZalobaResponse(
      count: json['count'],
      results: zalobaList,
    );
  }
}
