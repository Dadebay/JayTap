class ChatUser {
  final int id;
  final String username;
  final String? typeTitle;
  final String? img;
  final String name;
  final bool blok;
  final String? address;
  final String rating;
  final String? userStatusChanging;
  final String? imgUrl;
  final int productCount;
  final int premiumCount;
  final int viewCount;

  ChatUser({
    required this.id,
    required this.username,
    this.typeTitle,
    this.img,
    required this.name,
    required this.blok,
    this.address,
    required this.rating,
    this.userStatusChanging,
    this.imgUrl,
    required this.productCount,
    required this.premiumCount,
    required this.viewCount,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      username: json['username'] ?? '',
      typeTitle: json['type_title'],
      img: json['img'],
      name: json['name'] ?? 'No Name',
      blok: json['blok'] ?? false,
      address: json['address'],
      rating: (json['rating'] ?? '0.0').toString(),
      userStatusChanging: json['user_status_changing'],
      imgUrl: json['img_url'],
      productCount: json['productcount'] ?? 0,
      premiumCount: json['premiumcount'] ?? 0,
      viewCount: json['viewcount'] ?? 0,
    );
  }
}

class Conversation {
  final int id;
  final ChatUser? friend;
  final DateTime createdAt;
  String lastMessage;

  Conversation({
    required this.id,
    this.friend,
    required this.createdAt,
    this.lastMessage = "",
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      friend: json['friend'] != null ? ChatUser.fromJson(json['friend']) : null,
      createdAt: DateTime.parse(json['created_at']),
      lastMessage: json['last_message'] ?? "",
    );
  }


}

enum MessageStatus { sending, sent, failed }

class Message {
  final int id;
  final String content;
  final int senderId;
  final int conversation;
  final bool? read;
  final DateTime createdAt;
  final int? replyToId;
  String? repliedMessageContent;
  String? repliedMessageSender;
  final String? tempId;
  MessageStatus status;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
    this.read,
    required this.conversation,
    this.replyToId,
    this.repliedMessageContent,
    this.repliedMessageSender,
    this.tempId,
    this.status = MessageStatus.sent,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final senderValue = json['sender'] ?? json['sender_id'];

    return Message(
      id: _parseInt(json['id']) ?? -1,
      content: json['content'] ?? json['message'],
      senderId: _parseInt(senderValue) ?? 0,
      read: json['read'] ?? false,
      conversation: json['conversation'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      replyToId: _parseInt(json['reply_to'] ?? json['reply_id']),
      status: MessageStatus.sent,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
