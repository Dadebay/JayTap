import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/chat/views/chat_service.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';

import '../views/chat_model.dart';

enum WebSocketStatus { connecting, connected, disconnected, error }

class ChatController extends GetxController {
  RxBool isLoading = false.obs; // Added isLoading
  var canLoadMore = <int, bool>{}.obs;
  var connectionStatus = WebSocketStatus.disconnected.obs;
  var isLoadingMessages = <int, bool>{}.obs;
  var messagesMap = <int, RxList<Message>>{}.obs;
  var replyingToMessage = Rx<Message?>(null);
  var currentPage = <int, int>{}.obs;

  final ChatService _chatService = ChatService();
  final UserProfilController _userProfilController =
      Get.find<UserProfilController>();

  // New: Observable list for conversations
  RxList<Conversation> conversations = <Conversation>[].obs;
  Timer? _periodicUpdateTimer;

  @override
  void onInit() {
    super.onInit();
    fetchConversations(); // Initial fetch
    _startPeriodicConversationUpdate();
  }

  @override
  void onClose() {
    _chatService.disconnect();
    _periodicUpdateTimer?.cancel(); // Cancel the timer
    super.onClose();
  }

  void _startPeriodicConversationUpdate() {
    _periodicUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateLastMessagesForConversations();
    });
  }

  Future<void> _updateLastMessagesForConversations() async {
    for (var i = 0; i < conversations.length; i++) {
      final conversation = conversations[i];
      try {
        final latestMessage =
            await _chatService.getLatestMessageForConversation(conversation.id);
        if (latestMessage != null) {
          // Update the specific conversation in the RxList
          conversations[i] = Conversation(
            id: conversation.id,
            friend: conversation.friend,
            createdAt: latestMessage.createdAt, // Update timestamp
            lastMessage: latestMessage.content, // Update message content
          );
        }
      } catch (e) {
        print(
            "Error updating last message for conversation ${conversation.id}: $e");
      }
    }
  }

  Future<void> fetchConversations() async {
    try {
      isLoading.value = true; // Set loading to true
      var fetchedConversations = await _chatService.getConversations();
      conversations.assignAll(fetchedConversations); // Assign to RxList
    } catch (e) {
      print("Error fetching conversations: $e");
      // rethrow; // Don't rethrow, just log for initial fetch
    } finally {
      isLoading.value = false; // Set loading to false
    }
  }

  Future<void> fetchInitialMessages(int conversationId) async {
    isLoadingMessages[conversationId] = true;
    currentPage[conversationId] = 1; // NEW: Reset page for initial fetch
    update();

    try {
      final fetchedMessages = await _chatService.getMessages(conversationId,
          page: currentPage[conversationId]!); // Pass page
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
      canLoadMore[conversationId] =
          fetchedMessages.length >= 20; // Assuming 20 is the page size
    } catch (e) {
      print("Error fetching messages for $conversationId: $e");
    } finally {
      isLoadingMessages[conversationId] = false;
      update();
    }
  }

  // NEW: Function to load more messages
  Future<void> loadMoreMessages(int conversationId) async {
    if (isLoadingMessages[conversationId] == true ||
        canLoadMore[conversationId] == false) {
      return; // Prevent multiple simultaneous loads or if no more messages
    }

    isLoadingMessages[conversationId] = true;
    currentPage[conversationId] =
        (currentPage[conversationId] ?? 0) + 1; // Increment page
    update();

    try {
      final newMessages = await _chatService.getMessages(conversationId,
          page: currentPage[conversationId]!);
      if (newMessages.isNotEmpty) {
        final messageMap = {for (var msg in newMessages) msg.id: msg};
        for (var msg in newMessages) {
          if (msg.replyToId != null && messageMap.containsKey(msg.replyToId)) {
            final originalMsg = messageMap[msg.replyToId]!;
            msg.repliedMessageContent = originalMsg.content;

            msg.repliedMessageSender =
                originalMsg.senderId == _userProfilController.user.value!.id
                    ? "You"
                    : "Them";
          }
        }
        messagesMap[conversationId]
            ?.addAll(newMessages); // Add to existing messages
      }
      canLoadMore[conversationId] =
          newMessages.length >= 20; // Update canLoadMore
    } catch (e) {
      print("Error loading more messages for $conversationId: $e");
    } finally {
      isLoadingMessages[conversationId] = false;
      update();
    }
  }

  Future<void> connectToChat(
      {required int conversationId, required int friendId}) async {
    print(conversationId);
    print(friendId);

    if (_userProfilController.user.value == null) {
      await _userProfilController.fetchUserData();
      if (_userProfilController.user.value == null) {
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
            final existingOptimisticMessage = messages[tempMessageIndex];
            receivedMessage.repliedMessageContent =
                existingOptimisticMessage.repliedMessageContent;
            receivedMessage.repliedMessageSender =
                existingOptimisticMessage.repliedMessageSender;
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
    messagesMap[conversationId]!.value =
        List<Message>.from(messagesMap[conversationId]!.value);

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

  Future<void> deleteMessage(int messageId, int conversationId) async {
    try {
      await _chatService.deleteMessage(messageId);
      messagesMap[conversationId]?.removeWhere((msg) => msg.id == messageId);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete message: $e');
    }
  }
}
