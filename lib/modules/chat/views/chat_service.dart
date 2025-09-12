import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/chat/controllers/chat_controller.dart';
import 'package:jaytap/modules/chat/views/chat_model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  WebSocketChannel? _channel;

  Future<List<Conversation>> getConversations() async {
    final _token = await AuthStorage().token;
    print(_token);
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}chat/getconversations/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Conversation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  Future<List<Message>> getMessages(int conversationId, {int page = 1}) async {
    final _token = await AuthStorage().token;
    final url =
        '${ApiConstants.baseUrl}chat/getmessages/$conversationId/?page=$page';
    print(url);
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Message.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception(
          'Failed to load messages for conversation $conversationId');
    }
  }

  Future<Message?> getLatestMessageForConversation(int conversationId) async {
    try {
      final messages = await getMessages(conversationId);
      if (messages.isNotEmpty) {
        // Assuming messages are ordered by createdAt descending
        return messages.first;
      }
    } catch (e) {
      print(
          "Error fetching latest message for conversation $conversationId: $e");
    }
    return null;
  }

  void connect(
      {required int friendId,
      required int myId,
      required Function(Message) onMessageReceived,
      required Function(WebSocketStatus) onStatusChanged}) {
    onStatusChanged(WebSocketStatus.connecting);
    final url = ApiConstants.websocketURL + '/$myId/$friendId/';

    print('Connecting to WebSocket: $url');

    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(url));
      onStatusChanged(WebSocketStatus.connected);

      _channel?.stream.listen(
        (message) {
          final data = jsonDecode(message);
          print(data);
          final receivedMessage = Message.fromJson(data);
          onMessageReceived(receivedMessage);
        },
        onError: (error) {
          print('WebSocket Error: $error');
          onStatusChanged(WebSocketStatus.error);
        },
        onDone: () {
          print('WebSocket connection closed');
          onStatusChanged(WebSocketStatus.disconnected);
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('WebSocket connection failed: $e');
      onStatusChanged(WebSocketStatus.error);
    }
  }

  void sendMessage(String text, {int? replyToId}) {
    if (_channel == null) {
      print("WebSocket is not connected.");
      return;
    }
    final messagePayload = {
      'message': text,
      if (replyToId != null) 'reply_id': replyToId.toString(),
    };
    final jsonPayload = jsonEncode(messagePayload);
    print('>>> SENDING VIA WEBSOCKET: $jsonPayload');

    _channel?.sink.add(jsonPayload);
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  Future<Conversation> getOrCreateConversation(int friendId) async {
    final _token = await AuthStorage().token;
    final response = await http.post(
      Uri.parse(
          '${ApiConstants.baseUrl}chat/get-or-create-conversation/$friendId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Conversation.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      print(
          'Failed to get or create conversation. Status Code: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to get or create conversation');
    }
  }

  Future<void> deleteMessage(int messageId) async {
    final _token = await AuthStorage().token;
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}chat/deletemessages/$messageId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete message');
    }
  }
}
