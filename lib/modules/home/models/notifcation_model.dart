class PaginatedNotificationResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<UserNotification> results;

  PaginatedNotificationResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedNotificationResponse.fromJson(Map<String, dynamic> json) =>
      PaginatedNotificationResponse(
        count: json["count"],
        next: json["next"],
        previous: json["previous"],
        results: List<UserNotification>.from(
            json["results"].map((x) => UserNotification.fromJson(x))),
      );
}

// Bu iki model aynı kalacak, dokunmanıza gerek yok.
class UserNotification {
  final int id;
  final NotificationModel notification;

  UserNotification({
    required this.id,
    required this.notification,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) =>
      UserNotification(
        id: json["id"],
        notification: NotificationModel.fromJson(json["notification"]),
      );
}

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final bool send;
  final DateTime createdAt;
  final List<int> product;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.send,
    required this.createdAt,
    required this.product,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json["id"],
        title: json["title"],
        body: json["body"],
        send: json["send"],
        createdAt: DateTime.parse(json["created_at"]),
        product: List<int>.from(json["product"].map((x) => x)),
      );
}
