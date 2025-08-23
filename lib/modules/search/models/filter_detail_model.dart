class FilterDetailModel {
  final int id;
  final String? villageNameTm;
  final String? categoryTitleTk;

  FilterDetailModel({
    required this.id,
    this.villageNameTm,
    this.categoryTitleTk,
  });

  factory FilterDetailModel.fromJson(Map<String, dynamic> json) {
    return FilterDetailModel(
      id: json['id'] as int,
      villageNameTm: json['village__name_tm'] as String?,
      categoryTitleTk: json['category__title_tk'] as String?,
    );
  }
}
