// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';
// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/chat/chat_service.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';
import 'package:jaytap/modules/user_profile/model/user_model.dart';

import '../views/chat_model.dart';

enum WebSocketStatus { connecting, connected, disconnected, error }

class ChatController extends GetxController {
  // final AudioPlayer _audioPlayer = AudioPlayer();
  RxBool isLoading = false.obs;
  var canLoadMore = <int, bool>{}.obs;
  var connectionStatus = WebSocketStatus.disconnected.obs;
  var isLoadingMessages = <int, bool>{}.obs;
  var messagesMap = <int, RxList<Message>>{}.obs;
  var replyingToMessage = Rx<Message?>(null);
  var currentPage = <int, int>{}.obs;
  var unreadMessagesByConversation = <int, int>{}.obs;
  var totalUnreadCount = 0.obs;
  final ChatService _chatService = ChatService();
  final UserProfilController _userProfilController =
      Get.find<UserProfilController>();

  RxList<Conversation> conversations = <Conversation>[].obs;
  RxBool hasFetchedConversationsInitially = false.obs;
  var onlineFriends = <int>{}.obs;

  void markFriendOffline(int friendId) {
    onlineFriends.remove(friendId);
  }

  @override
  void onInit() {
    super.onInit();
    fetchConversations(showLoading: false);

    ever(_userProfilController.user, (UserModel? user) async {
      if (user != null) {
        await fetchConversations();
      } else {
        conversations.clear();
      }
    });
  }

  @override
  void onClose() {
    _chatService.disconnect();
    // _audioPlayer.dispose();
    super.onClose();
  }

  void updateTotalUnreadCount() {
    totalUnreadCount.value = unreadMessagesByConversation.values
        .fold(0, (sum, count) => sum + count);
  }

  void handleGlobalConversationUpdate(Map<String, dynamic> updateData) {
    // _audioPlayer.play(AssetSource('sounds/notification.wav'));
    final int? conversationId =
        int.tryParse(updateData['conversation_id'].toString());
    if (conversationId != null) {
      unreadMessagesByConversation[conversationId] =
          (unreadMessagesByConversation[conversationId] ?? 0) + 1;
      updateTotalUnreadCount();
    }

    final String? lastMessageContent = updateData['last_message'];
    final String? createdAtString = updateData['created_at'];

    if (conversationId == null ||
        lastMessageContent == null ||
        createdAtString == null) {
      print("Invalid global WebSocket update data: $updateData");
      return;
    }

    final DateTime createdAt = DateTime.parse(createdAtString);

    final conversationIndex = conversations.indexWhere(
      (conv) => conv.id == conversationId,
    );

    if (conversationIndex != -1) {
      final existingConversation = conversations[conversationIndex];
      final updatedConversation = Conversation(
        id: existingConversation.id,
        friend: existingConversation.friend,
        createdAt: createdAt,
        lastMessage: lastMessageContent,
      );
      conversations.removeAt(conversationIndex);
      if (_userProfilController.user.value != null) {
        final adminId = _userProfilController.user.value!.adminId;
        final adminConversationIndex =
            conversations.indexWhere((c) => c.friend?.id == adminId);

        if (updatedConversation.friend?.id == adminId) {
          conversations.insert(0, updatedConversation);
        } else {
          if (adminConversationIndex != -1) {
            conversations.insert(1, updatedConversation);
          } else {
            conversations.insert(0, updatedConversation);
          }
        }
      } else {
        conversations.insert(0, updatedConversation);
      }
    } else {
      print(
          "Received update for unknown conversation ID: $conversationId. Re-fetching conversations.");
      fetchConversations();
    }
  }

  Future<void> fetchConversations({bool showLoading = true}) async {
    try {
      var fetchedConversations = await _chatService.getConversations();
      conversations.assignAll(fetchedConversations);
    } catch (e) {
      print("Error fetching conversations: $e");
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
      hasFetchedConversationsInitially.value = true;
    }
  }

  Future<void> fetchInitialMessages(int conversationId) async {
    isLoadingMessages[conversationId] = true;
    currentPage[conversationId] = 1;
    update();

    try {
      final fetchedMessages = await _chatService.getMessages(conversationId,
          page: currentPage[conversationId]!);
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

  Future<void> loadMoreMessages(int conversationId) async {
    if (isLoadingMessages[conversationId] == true ||
        canLoadMore[conversationId] == false) {
      return;
    }

    isLoadingMessages[conversationId] = true;
    currentPage[conversationId] = (currentPage[conversationId] ?? 0) + 1;
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
        messagesMap[conversationId]?.addAll(newMessages);
      }
      canLoadMore[conversationId] = newMessages.length >= 20;
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
        print("Yeni Mesaj Geldi: ${receivedMessage}");
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

    final conversationIndex =
        conversations.indexWhere((c) => c.id == conversationId);
    if (conversationIndex != -1) {
      final conversation = conversations[conversationIndex];
      final updatedConversation = Conversation(
        id: conversation.id,
        friend: conversation.friend,
        lastMessage: text,
        createdAt: DateTime.now(),
      );
      conversations.removeAt(conversationIndex);
      if (_userProfilController.user.value != null) {
        final adminId = _userProfilController.user.value!.adminId;
        final adminConversationIndex =
            conversations.indexWhere((c) => c.friend?.id == adminId);

        if (updatedConversation.friend?.id == adminId) {
          conversations.insert(0, updatedConversation);
        } else {
          if (adminConversationIndex != -1) {
            conversations.insert(1, updatedConversation);
          } else {
            conversations.insert(0, updatedConversation);
          }
        }
      } else {
        conversations.insert(0, updatedConversation);
      }
    }

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
