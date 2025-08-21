// chat_models.dart


// Model for a user as returned by the conversation API
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
      rating: json['rating'] ?? '0.0',
      userStatusChanging: json['user_status_changing'],
      imgUrl: json['img_url'],
      productCount: json['productcount'] ?? 0,
      premiumCount: json['premiumcount'] ?? 0,
      viewCount: json['viewcount'] ?? 0,
    );
  }
}

// Model for the list of conversations from /getconversations
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

// Model for a single message from /getmessages and WebSocket
class Message {
  final int id;
  final String content;
  final int senderId;
  final DateTime createdAt;
  final int? replyToId; // ID of the message being replied to
  String? repliedMessageContent;
  String? repliedMessageSender;
  final String? tempId; // Geçici, benzersiz ID
  MessageStatus status; // Mesajın durumu

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
    this.replyToId,
    this.repliedMessageContent,
    this.repliedMessageSender,
    this.tempId, // <<< YENİ
    this.status = MessageStatus.sent,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] is int ? json['id'] : int.parse(json['id']),
      content: json['content'] ?? json['message'], // Handles both API and WS response
      senderId: json['sender'] ?? 0, // Assume sender is provided, default to 0
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
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
