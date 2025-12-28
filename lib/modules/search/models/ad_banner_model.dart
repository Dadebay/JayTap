class AdBannerModel {
  final int id;
  final String title;
  final String description;
  final double? lat;
  final double? long;
  final String img;

  AdBannerModel({
    required this.id,
    required this.title,
    required this.description,
    this.lat,
    this.long,
    required this.img,
  });

  factory AdBannerModel.fromJson(Map<String, dynamic> json) {
    return AdBannerModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      long: json['long'] != null ? double.tryParse(json['long'].toString()) : null,
      img: json['img'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'lat': lat?.toString(),
      'long': long?.toString(),
      'img': img,
    };
  }
}
