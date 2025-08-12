class PaginatedMapPropertyResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<MapPropertyModel> results;

  PaginatedMapPropertyResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedMapPropertyResponse.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List? ?? [];
    List<MapPropertyModel> propertyResults = list.map((i) => MapPropertyModel.fromJson(i)).toList();

    return PaginatedMapPropertyResponse(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: propertyResults,
    );
  }
}

class PaginatedPropertyResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<PropertyModel> results;

  PaginatedPropertyResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedPropertyResponse.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List? ?? [];
    List<PropertyModel> propertyResults = list.map((i) => PropertyModel.fromJson(i)).toList();

    return PaginatedPropertyResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: propertyResults,
    );
  }
}

class MapPropertyModel {
  final int id;
  final double? lat;
  final double? long;
  final int? price;
  final String? category;
  final String? subcat;

  MapPropertyModel({
    required this.id,
    this.lat,
    this.long,
    this.price,
    this.category,
    this.subcat,
  });

  factory MapPropertyModel.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return MapPropertyModel(
      id: json["id"],
      lat: _toDouble(json["lat"] ?? 0.0),
      long: _toDouble(json["long"] ?? 0.0),
      price: json["price"],
      category: json["category"].toString(),
      subcat: json["subcat"].toString(),
    );
  }
}

class SubCategory {
  final int? id;
  final String? name;
  final int? category;

  SubCategory({
    required this.id,
    this.name,
    this.category,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
        id: json["id"],
        name: json["name"],
        category: json["category"],
      );
}

class PropertyModel {
  final int id;
  final String? name;
  final Category? category;
  final String? address;
  final Region? region;
  final Village? village;
  final List<Specification>? remont;
  final List<Specification>? specification;
  final List<Extrainform>? extrainform;
  final int? price;
  final int? square;
  final bool? vip;
  final String? img;
  final double? lat;
  final double? long;
  final bool? show;
  final int? viewcount;
  final String? description;

  PropertyModel({
    required this.id,
    this.name,
    this.category,
    this.address,
    this.region,
    this.village,
    this.remont,
    this.specification,
    this.extrainform,
    this.price,
    this.square,
    this.vip,
    this.img,
    this.lat,
    this.long,
    this.show,
    this.viewcount,
    this.description,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) => PropertyModel(
        id: json["id"],
        name: json["name"],
        category: json["category"] == null ? null : Category.fromJson(json["category"]),
        address: json["address"],
        region: json["region"] == null ? null : Region.fromJson(json["region"]),
        village: json["village"] == null ? null : Village.fromJson(json["village"]),
        remont: json["remont"] == null ? [] : List<Specification>.from(json["remont"]!.map((x) => Specification.fromJson(x))),
        specification: json["specification"] == null ? [] : List<Specification>.from(json["specification"]!.map((x) => Specification.fromJson(x))),
        extrainform: json["extrainform"] == null ? [] : List<Extrainform>.from(json["extrainform"]!.map((x) => Extrainform.fromJson(x))),
        price: json["price"],
        square: json["square"],
        vip: json["vip"],
        img: json["img_url"],
        lat: json["x"]?.toDouble(),
        long: json["y"]?.toDouble(),
        show: json["show"],
        viewcount: json["viewcount"],
        description: json["description"],
      );
}

class Category {
  final int id;
  final String? titleTk;
  final String? titleEn;
  final String? titleRu;
  final String? imgUrl;

  Category({required this.id, this.titleTk, this.titleEn, this.titleRu, this.imgUrl});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        titleTk: json["title_tk"],
        titleEn: json["title_en"],
        titleRu: json["title_ru"],
        imgUrl: json["img_url"],
      );
}

class Region {
  final int id;
  final String? name;
  final Village? village;

  Region({required this.id, this.name, this.village});

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        id: json["id"],
        name: json["name"],
        village: json["village"] == null ? null : Village.fromJson(json["village"]),
      );
}

class Village {
  final int id;
  final String? name;

  Village({required this.id, this.name});

  factory Village.fromJson(Map<String, dynamic> json) => Village(
        id: json["id"],
        name: json["name"],
      );
}

class Specification {
  final int id;
  final String? name;
  final String? nameTm;
  final String? nameEn;
  final String? nameRu;

  Specification({required this.id, this.name, this.nameTm, this.nameEn, this.nameRu});

  factory Specification.fromJson(Map<String, dynamic> json) => Specification(
        id: json["id"],
        name: json["name"],
        nameTm: json["name_tm"],
        nameEn: json["name_en"],
        nameRu: json["name_ru"],
      );
}

class Extrainform {
  final int id;
  final String? name;
  final dynamic img;
  final bool? verification;
  final bool? status;

  Extrainform({
    required this.id,
    this.name,
    this.img,
    this.verification,
    this.status,
  });

  factory Extrainform.fromJson(Map<String, dynamic> json) => Extrainform(
        id: json["id"],
        name: json["name"],
        img: json["img"],
        verification: json["verification"],
        status: json["status"],
      );
}
