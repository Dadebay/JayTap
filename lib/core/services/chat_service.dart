import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/chat/controllers/chat_controller.dart';
import 'package:jaytap/modules/chat/views/chat_model.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService extends GetxService {
  WebSocketChannel? _channel;
  WebSocketChannel? _globalChannel;

  final AuthStorage _authStorage = Get.find<AuthStorage>();
  final UserProfilController _userProfilController =
      Get.find<UserProfilController>();
  late final ChatController _chatController;

  Future<ChatService> init() async {
    _chatController = Get.find<ChatController>();
    if (_authStorage.isLoggedIn) {
      await _userProfilController.fetchUserData();

      if (_userProfilController.user.value != null) {
        connectGlobalChat(
          myId: _userProfilController.user.value!.id,
          onNewMessage: (data) {
            print("Global WebSocket - New Message Received: $data");
            _chatController.handleGlobalConversationUpdate(data);
          },
          onStatusChanged: (status) {
            print("Global WebSocket Status Changed: $status");
          },
        );
      }
    }
    return this;
  }

  @override
  void onClose() {
    disconnectGlobalChat();
    super.onClose();
  }

  Future<List<Conversation>> getConversations() async {
    final _token = await AuthStorage().token;
    if (_token == null) return [];
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
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );
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

    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(url));
      onStatusChanged(WebSocketStatus.connected);

      _channel?.stream.listen(
        (message) {
          final data = jsonDecode(message);
          final receivedMessage = Message.fromJson(data);
          onMessageReceived(receivedMessage);
        },
        onError: (error) {
          onStatusChanged(WebSocketStatus.error);
        },
        onDone: () {
          onStatusChanged(WebSocketStatus.disconnected);
        },
        cancelOnError: true,
      );
    } catch (e) {
      onStatusChanged(WebSocketStatus.error);
    }
  }

  void sendMessage(String text, {int? replyToId}) {
    if (_channel == null) {
      return;
    }
    final messagePayload = {
      'message': text,
      if (replyToId != null) 'reply_id': replyToId.toString(),
    };
    final jsonPayload = jsonEncode(messagePayload);
    _channel?.sink.add(jsonPayload);
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void connectGlobalChat({
    required int myId,
    required Function(dynamic) onNewMessage,
    required Function(WebSocketStatus) onStatusChanged,
  }) {
    onStatusChanged(WebSocketStatus.connecting);
    final url = 'wss://jaytap.com.tm/ws/getchat/$myId/';

    try {
      _globalChannel = IOWebSocketChannel.connect(Uri.parse(url));
      onStatusChanged(WebSocketStatus.connected);

      _globalChannel?.stream.listen(
        (message) {
          final data = jsonDecode(message);
          onNewMessage(data);
        },
        onError: (error) {
          onStatusChanged(WebSocketStatus.error);
        },
        onDone: () {
          onStatusChanged(WebSocketStatus.disconnected);
        },
        cancelOnError: true,
      );
    } catch (e) {
      onStatusChanged(WebSocketStatus.error);
    }
  }

  void disconnectGlobalChat() {
    _globalChannel?.sink.close();
    _globalChannel = null;
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
