import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/chat/views/chat_service.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';
import '../views/chat_model.dart';

enum WebSocketStatus { connecting, connected, disconnected, error }

class ChatController extends GetxController {
  var canLoadMore = <int, bool>{}.obs;
  var connectionStatus = WebSocketStatus.disconnected.obs;
  var isLoadingMessages = <int, bool>{}.obs;
  var messagesMap = <int, RxList<Message>>{}.obs;
  var replyingToMessage = Rx<Message?>(null);

  final ChatService _chatService = ChatService();
  final UserProfilController _userProfilController =
      Get.find<UserProfilController>();

  @override
  void onClose() {
    _chatService.disconnect();
    super.onClose();
  }

  Future<List<Conversation>> fetchConversations() async {
    try {
      var fetchedConversations = await _chatService.getConversations();
      return fetchedConversations;
    } catch (e) {
      print("Error fetching conversations: $e");
      rethrow;
    }
  }

  Future<void> fetchInitialMessages(int conversationId) async {
    if (messagesMap.containsKey(conversationId)) return;

    isLoadingMessages[conversationId] = true;
    update();

    try {
      final fetchedMessages = await _chatService.getMessages(conversationId);
      final messageMap = {for (var msg in fetchedMessages) msg.id: msg};

      for (var msg in fetchedMessages) {
        if (msg.replyToId != null && messageMap.containsKey(msg.replyToId)) {
          final originalMsg = messageMap[msg.replyToId]!;
          msg.repliedMessageContent = originalMsg.content;

          msg.repliedMessageSender =
              originalMsg.senderId == _userProfilController.user.value!.id
                  ? "You"
                  : "Them";
        }
      }

      messagesMap[conversationId] = fetchedMessages.obs;
      canLoadMore[conversationId] = fetchedMessages.length >= 20;
    } catch (e) {
      print("Error fetching messages for $conversationId: $e");
    } finally {
      isLoadingMessages[conversationId] = false;
      update();
    }
  }

  Future<void> connectToChat(
      {required int conversationId, required int friendId}) async {
    print(conversationId);
    print(friendId);

    // Ensure user data is loaded before proceeding
    if (_userProfilController.user.value == null) {
      await _userProfilController.fetchUserData();
      if (_userProfilController.user.value == null) {
        // User data still null after fetching, cannot proceed with chat
        print("Error: User data is null, cannot connect to chat.");
        connectionStatus.value = WebSocketStatus.error;
        return;
      }
    }

    await fetchInitialMessages(conversationId);
    _chatService.connect(
      friendId: friendId,
      myId: _userProfilController.user.value!.id,
      onMessageReceived: (Message receivedMessage) {
        final messages = messagesMap[conversationId];
        if (messages == null) return;

        if (receivedMessage.senderId == _userProfilController.user.value!.id) {
          final tempMessageIndex = messages.indexWhere((m) =>
              m.status == MessageStatus.sending &&
              m.content == receivedMessage.content &&
              m.replyToId == receivedMessage.replyToId);

          if (tempMessageIndex != -1) {
            // Preserve replied message info from the optimistic message
            // if the received message doesn't contain it, or if it's more accurate.
            // Assuming receivedMessage from backend might not always have this.
            final existingOptimisticMessage = messages[tempMessageIndex];
            receivedMessage.repliedMessageContent = existingOptimisticMessage.repliedMessageContent;
            receivedMessage.repliedMessageSender = existingOptimisticMessage.repliedMessageSender;
            messages[tempMessageIndex] = receivedMessage;
          }

          return;
        }

        if (receivedMessage.replyToId != null) {
          final originalMessage = messages
              .firstWhereOrNull((m) => m.id == receivedMessage.replyToId);
          if (originalMessage != null) {
            receivedMessage.repliedMessageContent = originalMessage.content;
            receivedMessage.repliedMessageSender = "Them";
          }
        }

        messages.insert(0, receivedMessage);
      },
      onStatusChanged: (status) {
        print("WebSocket Status Changed: $status");
        connectionStatus.value = status;
      },
    );
  }

  void sendMessage(
      {required int conversationId,
      required TextEditingController controller}) {
    if (connectionStatus.value != WebSocketStatus.connected) {
      Get.snackbar("noConnection1", "waitForConnection");

      return;
    }
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final optimisticMessage = Message(
      id: -1,
      tempId: tempId,
      content: text,
      senderId: _userProfilController.user.value!.id,
      createdAt: DateTime.now(),
      replyToId: replyingToMessage.value?.id,
      repliedMessageContent: replyingToMessage.value?.content,
      repliedMessageSender: "You",
      status: MessageStatus.sending,
      conversation: conversationId,
    );

    messagesMap[conversationId]?.insert(0, optimisticMessage);
    messagesMap[conversationId]!.value = List<Message>.from(messagesMap[conversationId]!.value);

    _chatService.sendMessage(text, replyToId: replyingToMessage.value?.id);

    controller.clear();
    cancelReply();
  }

  void disconnectFromChat() {
    _chatService.disconnect();
    connectionStatus.value = WebSocketStatus.disconnected;
  }

  void setReplyTo(Message message) {
    replyingToMessage.value = message;
  }

  void cancelReply() {
    replyingToMessage.value = null;
  }

  Future<Conversation?> getOrCreateConversation(int friendId) async {
    try {
      final conversation = await _chatService.getOrCreateConversation(friendId);
      return conversation;
    } catch (e) {
      Get.snackbar('Error', 'Could not start chat: $e');
      return null;
    }
  }

  Future<void> deleteMessage(int messageId, int conversationId) async {
    try {
      await _chatService.deleteMessage(messageId);
      messagesMap[conversationId]?.removeWhere((msg) => msg.id == messageId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete message: $e');
    }
  }
}
