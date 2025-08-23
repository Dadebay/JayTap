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
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}chat/getconversations/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      print(body);
      return body.map((dynamic item) => Conversation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  // Fetches a page of messages for a specific conversation
  Future<List<Message>> getMessages(int conversationId, {int page = 1}) async {
    final _token = await AuthStorage().token;

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}chat/getmessages/$conversationId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      // Mesajlar başarıyla bulundu, listeyi döndür.
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Message.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      // <<<--- YENİ KOD BURADA ---
      // 404: Sohbet var ama içinde mesaj yok. Bu bir hata değil. Boş liste döndür.
      return [];
    } else {
      // Diğer tüm hatalar (500, 401 vb.) için exception fırlat.
      throw Exception('Failed to load messages for conversation $conversationId');
    }
  }

  // Connects to the WebSocket
  void connect({required int friendId, required int myId, required Function(Message) onMessageReceived, required Function(WebSocketStatus) onStatusChanged}) {
    onStatusChanged(WebSocketStatus.connecting);

    final url = 'ws://216.250.10.237:9000/ws/chat/$myId/$friendId/';
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

  // Sends a message via WebSocket
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
    print('>>> SENDING VIA WEBSOCKET: $jsonPayload'); // Gönderilen JSON'ı konsolda gör

    _channel?.sink.add(jsonPayload);
    // _channel?.sink.add(jsonEncode(messagePayload));
  }

  // Disconnects from WebSocket
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
