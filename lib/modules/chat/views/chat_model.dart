// chat_model.dart
class ChatModel {
  final int id;
  final String username;
  final String lastMessage;
  final String photo;

  ChatModel({required this.id, required this.username, required this.lastMessage, required this.photo});
}

class Message {
  final String id;
  final int senderId;
  final String content;
  final DateTime dateTime;
  final String? imagePath;
  final MessageType type;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.dateTime,
    this.imagePath,
    this.type = MessageType.text,
  });
}

enum MessageType { text, image }
