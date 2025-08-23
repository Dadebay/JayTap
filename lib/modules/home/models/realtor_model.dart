// lib/modules/home/models/realtor_model.dart

// API'den gelen tüm yanıtı temsil eden sınıf
class RealtorResponse {
  final int count;
  final dynamic next;
  final dynamic previous;
  final List<RealtorModel> results;

  RealtorResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory RealtorResponse.fromJson(Map<String, dynamic> json) =>
      RealtorResponse(
        count: json["count"],
        next: json["next"] ?? '',
        previous: json["previous"] ?? '',
        results: List<RealtorModel>.from(
            json["results"].map((x) => RealtorModel.fromJson(x))),
      );
}

// Tek bir emlakçı (kullanıcı) nesnesini temsil eden sınıf
class RealtorModel {
  final int id;
  final String username;
  final String? typeTitle;
  final String? img; // Null olabilir
  final String? name; // Null olabilir
  final bool blok;
  final String? rating;
  final String? userStatusChanging;
  final String? address;

  RealtorModel({
    required this.id,
    required this.username,
    this.typeTitle,
    this.img,
    this.name,
    required this.blok,
    required this.address,
    required this.rating,
    required this.userStatusChanging,
  });

  factory RealtorModel.fromJson(Map<String, dynamic> json) => RealtorModel(
        id: json["id"],
        username: json["username"] ?? '',
        typeTitle: json["type_title"] ?? '',
        img: json["img_url"] ?? '',
        name: json["name"] ?? '',
        blok: json["blok"] ?? false,
        rating: json["rating"].toString(),
        address: json["address"] ?? '',
        userStatusChanging: json["user_status_changing"] ?? '',
      );
}
