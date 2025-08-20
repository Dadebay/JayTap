import 'package:get/get.dart';

class SavedFilterModel {
  final int? id;
  final int? floorcount;
  final int? totalfloorcount;
  final int? roomcount;
  final double? minsquare;
  final double? maxsquare;
  final String? owner;
  final double? maxprice;
  final double? minprice;
  final int? category;
  final int? subcategory;
  final int? subincategory;
  final int? village;
  final int? remont;
  final int? accaunt; // Typo in original request, assuming 'account'

  SavedFilterModel({
    this.id,
    this.floorcount,
    this.totalfloorcount,
    this.roomcount,
    this.minsquare,
    this.maxsquare,
    this.owner,
    this.maxprice,
    this.minprice,
    this.category,
    this.subcategory,
    this.subincategory,
    this.village,
    this.remont,
    this.accaunt,
  });

  factory SavedFilterModel.fromJson(Map<String, dynamic> json) {
    return SavedFilterModel(
      id: json['id'],
      floorcount: json['floorcount'],
      totalfloorcount: json['totalfloorcount'],
      roomcount: json['roomcount'],
      minsquare: (json['minsquare'] as num?)?.toDouble(),
      maxsquare: (json['maxsquare'] as num?)?.toDouble(),
      owner: json['owner'],
      maxprice: (json['maxprice'] as num?)?.toDouble(),
      minprice: (json['minprice'] as num?)?.toDouble(),
      category: json['category'],
      subcategory: json['subcategory'],
      subincategory: json['subincategory'],
      village: json['village'],
      remont: json['remont'],
      accaunt: json['accaunt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'floorcount': floorcount,
      'totalfloorcount': totalfloorcount,
      'roomcount': roomcount,
      'minsquare': minsquare,
      'maxsquare': maxsquare,
      'owner': owner,
      'maxprice': maxprice,
      'minprice': minprice,
      'category': category,
      'subcategory': subcategory,
      'subincategory': subincategory,
      'village': village,
      'remont': remont,
      'accaunt': accaunt,
    };
  }

  // A simple way to generate a display name for the filter
  String get name {
    List<String> parts = [];
    if (roomcount != null && roomcount! > 0) parts.add('$roomcount rooms');
    if (minprice != null && minprice! > 0) parts.add('min ${minprice}TMT');
    if (maxprice != null && maxprice! > 0) parts.add('max ${maxprice}TMT');
    if (minsquare != null && minsquare! > 0) parts.add('min ${minsquare}m²');
    if (maxsquare != null && maxsquare! > 0) parts.add('max ${maxsquare}m²');
    if (owner != null && owner!.isNotEmpty) parts.add(owner!); // Assuming owner is 'owner' or 'realtor'
    // Add more fields as needed for a descriptive name
    return parts.isEmpty ? 'Unnamed Filter' : parts.join(', ');
  }
}
