import 'package:get/get.dart';
import 'package:jaytap/core/services/api_constants.dart';

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
    List<MapPropertyModel> propertyResults =
        list.map((i) => MapPropertyModel.fromJson(i)).toList();

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
    List<PropertyModel> propertyResults =
        list.map((i) => PropertyModel.fromJson(i)).toList();

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
  final String? titleTk;
  final String? titleEn;
  final String? titleRu;
  final int? category;
  final List<SubCategory>? subin;

  SubCategory({
    this.id,
    this.titleTk,
    this.titleEn,
    this.titleRu,
    this.category,
    this.subin,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
        id: json["id"],
        titleTk: json["title_tk"],
        titleEn: json["title_en"],
        titleRu: json["title_ru"],
        category: json["category"],
        subin: json["subin"] == null
            ? []
            : List<SubCategory>.from(
                json["subin"]!.map((x) => SubCategory.fromJson(x))),
      );

  String? get name {
    final locale = Get.locale?.languageCode ?? 'tr';
    switch (locale) {
      case 'en':
        return titleEn;
      case 'ru':
        return titleRu;
      case 'tr':
        return titleTk;
      default:
        return titleTk;
    }
  }
}

class OwnerModel {
  final int id;
  final String? username;
  final String? typeTitle;
  final String? imgUrl;
  final String? name;
  final int? productcount;
  final int? viewcount;

  OwnerModel({
    required this.id,
    this.username,
    this.typeTitle,
    this.imgUrl,
    this.name,
    this.productcount,
    this.viewcount,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) => OwnerModel(
        id: json["id"],
        username: json["username"],
        typeTitle: json["type_title"],
        imgUrl: json["img_url"],
        name: json["name"],
        productcount: json["productcount"],
        viewcount: json["viewcount"],
      );
}

class PropertySpecification {
  final int id;
  final Specification spec;
  final int count;

  PropertySpecification({
    required this.id,
    required this.spec,
    required this.count,
  });

  factory PropertySpecification.fromJson(Map<String, dynamic> json) =>
      PropertySpecification(
        id: json["id"],
        spec: Specification.fromJson(json["spec"]),
        count: json["count"],
      );
}

class PropertyModel {
  final int id;
  final String? name;
  final Category? category;
  final String? address;
  final Region? region;
  final Village? village;
  final List<RemontOption>? remont;
  final List<PropertySpecification>? specifications;
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

  final int? roomcount;
  final int? floorcount;
  final int? totalfloorcount;
  final OwnerModel? owner;
  final List<dynamic>? comments;
  final String? phoneNumber;
  final int? villageId;
  final int? regionId;
  final int? categoryId;
  final int? subcatId;
  final int? subincatId;
  final List<Sphere>? sphere;
  final List<String>? imgUrlAnother;
  final String? confirm;
  final List<VrModel>? vr;
  final String? otkaz;

  PropertyModel({
    required this.id,
    this.name,
    this.category,
    this.address,
    this.region,
    this.village,
    this.remont,
    this.specifications,
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
    this.roomcount,
    this.floorcount,
    this.totalfloorcount,
    this.owner,
    this.comments,
    this.phoneNumber,
    this.villageId,
    this.regionId,
    this.categoryId,
    this.subcatId,
    this.subincatId,
    this.sphere,
    this.imgUrlAnother,
    this.confirm,
    this.vr,
    this.otkaz,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return PropertyModel(
      id: json["id"],
      name: json["name"],
      category:
          json["category"] == null ? null : Category.fromJson(json["category"]),
      address: json["address"],
      region: json["region"] == null ? null : Region.fromJson(json["region"]),
      village:
          json["village"] == null ? null : Village.fromJson(json["village"]),
      remont: json["remont"] == null
          ? []
          : List<RemontOption>.from(
              json["remont"]!.map((x) => RemontOption.fromJson(x))),
      specifications: json["specifications"] == null
          ? []
          : List<PropertySpecification>.from(json["specifications"]!
              .map((x) => PropertySpecification.fromJson(x))),
      extrainform: json["extrainform"] == null
          ? []
          : List<Extrainform>.from(
              json["extrainform"]!.map((x) => Extrainform.fromJson(x))),
      price: json["price"],
      square: json["square"],
      vip: json["vip"],
      img: json["img_url"],
      lat: _toDouble(json["lat"] ?? json["x"]),
      long: _toDouble(json["long"] ?? json["y"]),
      show: json["show"],
      viewcount: json["viewcount"],
      description: json["description"],
      roomcount: json["roomcount"],
      floorcount: json["floorcount"],
      totalfloorcount: json["totalfloorcount"],
      owner: json["owner"] == null ? null : OwnerModel.fromJson(json["owner"]),
      comments:
          json["comments"] == null ? [] : List<dynamic>.from(json["comments"]),
      phoneNumber: json["phone_number"],
      villageId: json["village_id"],
      regionId: json["region_id"],
      categoryId: json["category_id"],
      subcatId: json["subcat_id"],
      subincatId: json["subincat_id"],
      sphere: json["sphere"] == null
          ? []
          : List<Sphere>.from(json["sphere"]!.map((x) => Sphere.fromJson(x))),
      imgUrlAnother: (json["img_url_another"] is List)
          ? (json["img_url_another"] as List).map((e) => e.toString()).toList()
          : null,
      confirm: json["confirm"],
      vr: json["vr"] == null
          ? []
          : List<VrModel>.from(json["vr"]!.map((x) => VrModel.fromJson(x))),
      otkaz: json["otkaz"],
    );
  }
}

class Category {
  final int id;
  final String? titleTk;
  final String? titleEn;
  final String? titleRu;
  final String? imgUrl;
  final List<SubCategory> subcategory;

  Category({
    required this.id,
    this.titleTk,
    this.titleEn,
    this.titleRu,
    this.imgUrl,
    required this.subcategory,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var subcategoryList = json['subcategory'] as List? ?? [];
    List<SubCategory> subcategories =
        subcategoryList.map((i) => SubCategory.fromJson(i)).toList();

    return Category(
      id: json["id"],
      titleTk: json["title_tk"],
      titleEn: json["title_en"],
      titleRu: json["title_ru"],
      imgUrl: json["img_url"],
      subcategory: subcategories,
    );
  }

  String? get name {
    final locale = Get.locale?.languageCode ?? 'tr';
    switch (locale) {
      case 'en':
        return titleEn;
      case 'ru':
        return titleRu;
      case 'tr':
        return titleTk;
      default:
        return titleTk;
    }
  }
}

class PaginatedCategoryResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Category> results;

  PaginatedCategoryResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedCategoryResponse.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List? ?? [];
    List<Category> categoryResults =
        list.map((i) => Category.fromJson(i)).toList();

    return PaginatedCategoryResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: categoryResults,
    );
  }
}

class Region {
  final int id;
  final String? nameTm;
  final String? nameRu;
  final String? nameEn;
  final int? village;

  Region(
      {required this.id, this.nameTm, this.nameRu, this.nameEn, this.village});

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        id: json["id"],
        nameTm: json["name_tm"],
        nameRu: json["name_ru"],
        nameEn: json["name_en"],
        village: json["village"],
      );
  String? get name {
    final locale = Get.locale?.languageCode ?? 'tr';
    switch (locale) {
      case 'en':
        return nameEn;
      case 'ru':
        return nameRu;
      case 'tr':
        return nameTm;
      default:
        return nameTm;
    }
  }
}

class PaginatedVillageResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Village> results;

  PaginatedVillageResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedVillageResponse.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List? ?? [];
    List<Village> villageResults =
        list.map((i) => Village.fromJson(i)).toList();

    return PaginatedVillageResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: villageResults,
    );
  }
}

class Village {
  final int id;
  final String? nameTm;
  final String? nameRu;
  final String? nameEn;

  Village({required this.id, this.nameTm, this.nameRu, this.nameEn});

  factory Village.fromJson(Map<String, dynamic> json) => Village(
        id: json["id"],
        nameTm: json["name_tm"],
        nameRu: json["name_ru"],
        nameEn: json["name_en"],
      );

  String? get name {
    final locale = Get.locale?.languageCode ?? 'tr';
    switch (locale) {
      case 'en':
        return nameEn;
      case 'ru':
        return nameRu;
      case 'tr':
        return nameTm;
      default:
        return nameTm;
    }
  }
}

class Sphere {
  final int id;
  final String? nameTm;
  final String? nameRu;
  final String? nameEn;

  Sphere({required this.id, this.nameTm, this.nameRu, this.nameEn});

  factory Sphere.fromJson(Map<String, dynamic> json) => Sphere(
        id: json["id"],
        nameTm: json["title_tm"],
        nameRu: json["title_ru"],
        nameEn: json["title_en"],
      );

  String? get name {
    final locale = Get.locale?.languageCode ?? 'tr';
    switch (locale) {
      case 'en':
        return nameEn;
      case 'ru':
        return nameRu;
      case 'tr':
        return nameTm;
      default:
        return nameTm;
    }
  }
}

class Specification {
  final int id;
  final String? nameTm;
  final String? nameRu;
  final String? nameEn;

  Specification({required this.id, this.nameTm, this.nameRu, this.nameEn});

  factory Specification.fromJson(Map<String, dynamic> json) => Specification(
        id: json["id"],
        nameTm: json["name_tm"],
        nameRu: json["name_ru"],
        nameEn: json["name_en"],
      );

  String? get name {
    final locale = Get.locale?.languageCode ?? 'tr';
    switch (locale) {
      case 'en':
        return nameEn;
      case 'ru':
        return nameRu;
      case 'tr':
        return nameTm;
      default:
        return nameTm;
    }
  }
}

class Extrainform {
  final int id;
  final String? name;
  final dynamic img;
  final bool? verification;
  final bool? status;
  RxBool isSelected;

  Extrainform({
    required this.id,
    this.name,
    this.img,
    this.verification,
    this.status,
    bool initialValue = false,
  }) : isSelected = initialValue.obs;

  factory Extrainform.fromJson(Map<String, dynamic> json) => Extrainform(
        id: json["id"],
        name: json["name"],
        img: json["img"],
        verification: json["verification"],
        status: json["status"],
        initialValue: false,
      );
}

class LimitData {
  final int id;
  final int minRoom;
  final int maxRoom;
  final int minFloor;
  final int maxFloor;
  final int userLimit;
  final int userPluse;
  final int rieltor;
  final int company;

  LimitData({
    required this.id,
    required this.minRoom,
    required this.maxRoom,
    required this.minFloor,
    required this.maxFloor,
    required this.userLimit,
    required this.userPluse,
    required this.rieltor,
    required this.company,
  });

  factory LimitData.fromJson(Map<String, dynamic> json) => LimitData(
        id: json["id"],
        minRoom: json["min_room"],
        maxRoom: json["max_room"],
        minFloor: json["min_floor"],
        maxFloor: json["max_floor"],
        userLimit: json["user_limit"],
        userPluse: json["user_pluse"],
        rieltor: json["rieltor"],
        company: json["company"],
      );
}

class PaginatedLimitResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<LimitData> results;

  PaginatedLimitResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedLimitResponse.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List? ?? [];
    List<LimitData> limitResults =
        list.map((i) => LimitData.fromJson(i)).toList();

    return PaginatedLimitResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: limitResults,
    );
  }
}

class RemontOption {
  final int id;
  final String name;

  RemontOption({
    required this.id,
    required this.name,
  });

  factory RemontOption.fromJson(Map<String, dynamic> json) => RemontOption(
        id: json["id"],
        name: json["name"],
      );
}

class PaginatedSphereResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Sphere> results;

  PaginatedSphereResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedSphereResponse.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List? ?? [];
    List<Sphere> sphereResults = list.map((i) => Sphere.fromJson(i)).toList();

    return PaginatedSphereResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: sphereResults,
    );
  }
}

class VrModel {
  final int id;
  final String title;
  final double lat;
  final double long;
  final String imgPath;

  VrModel({
    required this.id,
    required this.title,
    required this.lat,
    required this.long,
    required this.imgPath,
  });

  // Backend'den gelen göreceli URL'yi tam URL'ye çeviren getter
  String get imageUrl {
    return "${ApiConstants.baseUrl}$imgPath";
  }

  factory VrModel.fromJson(Map<String, dynamic> json) {
    // String olarak gelen lat/long değerlerini double'a çeviriyoruz
    double _toDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return VrModel(
      id: json["id"],
      title: json["title"] ?? "Bilinmeyen Oda",
      lat: _toDouble(json["lat"]),
      long: _toDouble(json["long"]),
      imgPath: json["img"],
    );
  }
}
