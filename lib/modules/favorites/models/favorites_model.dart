class FavoriteStatus {
  final String status;

  FavoriteStatus({required this.status});

  factory FavoriteStatus.fromJson(Map<String, dynamic> json) {
    return FavoriteStatus(
      status: json['status'] ?? 'unknown',
    );
  }
}
