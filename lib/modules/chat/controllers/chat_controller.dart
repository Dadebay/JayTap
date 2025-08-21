import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/chat/views/chat_service.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';

import '../views/chat_model.dart';

enum WebSocketStatus { connecting, connected, disconnected, error }

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final UserProfilController _userProfilController = Get.find<UserProfilController>();
  var connectionStatus = WebSocketStatus.disconnected.obs;

  var messagesMap = <int, RxList<Message>>{}.obs;
  var isLoadingMessages = <int, bool>{}.obs;
  var canLoadMore = <int, bool>{}.obs;
  // var messageTextController = TextEditingController();

  var replyingToMessage = Rx<Message?>(null);

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    _chatService.disconnect();
    // messageTextController.dispose();
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

          msg.repliedMessageSender = originalMsg.senderId == _userProfilController.user.value!.id ? "You" : "Them";
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


  void connectToChat({required int conversationId, required int friendId}) {
    fetchInitialMessages(conversationId).then((_) {
      _chatService.connect(
        friendId: friendId,
        myId: _userProfilController.user.value!.id,

        // <<< SADECE BU KISMI AŞAĞIDAKİ İLE DEĞİŞTİR >>>
        onMessageReceived: (Message receivedMessage) {
          final messages = messagesMap[conversationId];
          if (messages == null) return;

          // 1. ADIM: Gelen mesajın göndericisi ben miyim? (Sunucudan gelen yankı)
          if (receivedMessage.senderId == _userProfilController.user.value!.id) {
            // EVET, BU BENİM MESAJIM.
            // Şimdi "gönderiliyor" durumundaki geçici versiyonunu bulup güncellemeliyim.

            final tempMessageIndex =
                messages.indexWhere((m) => m.status == MessageStatus.sending && m.content == receivedMessage.content && m.replyToId == receivedMessage.replyToId // Yanıtları da kontrol et
                    );

            // Geçici mesajı bulabildim mi?
            if (tempMessageIndex != -1) {
              // Evet, buldum. Geçici mesajı sunucudan gelen gerçek mesajla değiştiriyorum.
              messages[tempMessageIndex] = receivedMessage;
            }

            // EN ÖNEMLİ KISIM:
            // İşlem bitti. Bu benim mesajım olduğu için asla listeye tekrar eklenmemeli.
            // Bu yüzden fonksiyondan hemen çıkıyorum.
            return;
          }

          // 2. ADIM: EĞER KOD BURAYA GELDİYSE, MESAJ KARŞI TARAFTANDIR.
          // Bu yüzden onu listeye ekleyebiliriz.

          // Gelen yeni mesaj bir yanıtsa, bilgilerini doldur.
          if (receivedMessage.replyToId != null) {
            final originalMessage = messages.firstWhereOrNull((m) => m.id == receivedMessage.replyToId);
            if (originalMessage != null) {
              receivedMessage.repliedMessageContent = originalMessage.content;
              receivedMessage.repliedMessageSender = "Them"; // Basit tutuyoruz
            }
          }

          // Karşıdan gelen yeni mesajı listeye ekle.
          messages.insert(0, receivedMessage);
        },

        onStatusChanged: (status) {
          print("WebSocket Status Changed: $status");
          connectionStatus.value = status;
        },
      );
    });
  }

  void sendMessage({required int conversationId, required TextEditingController controller}) {
    if (connectionStatus.value != WebSocketStatus.connected) {
      Get.snackbar("Connection Error", "You are not connected to the chat. Please wait.");

      return;
    }
    final text = controller.text.trim();
    if (text.isEmpty) return;

    // 1. "Gönderiliyor" durumunda geçici bir mesaj oluştur
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final optimisticMessage = Message(
      id: -1, // Henüz gerçek ID yok
      tempId: tempId,
      content: text,
      senderId: _userProfilController.user.value!.id,
      createdAt: DateTime.now(),
      replyToId: replyingToMessage.value?.id,
      repliedMessageContent: replyingToMessage.value?.content,
      repliedMessageSender: "You",
      status: MessageStatus.sending, // <<< DURUM: GÖNDERİLİYOR
    );

    // 2. Bu geçici mesajı hemen listeye ekle (Optimistic UI)
    messagesMap[conversationId]?.insert(0, optimisticMessage);

    // 3. Gerçek mesajı sunucuya gönder
    _chatService.sendMessage(text, replyToId: replyingToMessage.value?.id);

    controller.clear();
    cancelReply();
  }

  void disconnectFromChat() {
    _chatService.disconnect();
    connectionStatus.value = WebSocketStatus.disconnected; // <<< YENİ: Durumu manuel olarak ayarla
  }

  void setReplyTo(Message message) {
    replyingToMessage.value = message;
  }

  void cancelReply() {
    replyingToMessage.value = null;
  }
}
