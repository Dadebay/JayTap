import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/chat/controllers/chat_controller.dart';
import 'package:jaytap/modules/chat/views/chat_model.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';

class ChatScreen extends StatefulWidget {
  final Conversation? conversation;
  final ChatUser? userModel;
  const ChatScreen({Key? key, this.conversation, this.userModel}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController controller = Get.find<ChatController>();
  final ScrollController _scrollController = ScrollController();
  final UserProfilController _userProfilController = Get.find<UserProfilController>();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.connectToChat(conversationId: widget.conversation!.id, friendId: widget.userModel!.id);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        print("Reached the top, load more messages...");
      }
    });
  }

  @override
  void dispose() {
    controller.disconnectFromChat();
    controller.cancelReply();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.conversation == null) {
      return Scaffold(body: Center(child: Text("Sohbet bulunamadı.")));
    }

    final messages = controller.messagesMap[widget.conversation?.id] ?? <Message>[].obs;

    return Scaffold(
      appBar: _buildDefaultAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoadingMessages[widget.conversation?.id] == true && messages.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }
              if (messages.isEmpty) {
                return Center(
                  child: Text("Henüz hiç mesaj yok. İlk mesajı gönderin!"),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: EdgeInsets.all(8.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.senderId == _userProfilController.user.value!.id;

                  return Dismissible(
                    key: Key(msg.id.toString()),
                    direction: DismissDirection.startToEnd,
                    confirmDismiss: (direction) async {
                      controller.setReplyTo(msg);
                      return false;
                    },
                    background: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Icon(Icons.reply, color: Colors.grey),
                      ),
                    ),
                    child: ChatBubble(
                      message: msg,
                      isMe: isMe,
                    ),
                  );
                },
              );
            }),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  AppBar _buildDefaultAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey,
      // title'ı Obx ile sararak sadece bu kısmın güncellenmesini sağlıyoruz.
      title: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userModel!.name),
            _buildConnectionStatusSubtitle(controller.connectionStatus.value), // <<< YENİ: Durum alt başlığı
          ],
        );
      }),
      // AppBar'ın geri kalanı
      flexibleSpace: Row(
        children: [
          // CircleAvatar'ı doğrudan Row içine koymak yerine
          // AppBar'ın title'ına yerleştirmek daha standart bir yaklaşımdır.
          // Bu kısmı sizin tasarımınıza göre düzenleyebilirsiniz.
          // Örnek:
          // CircleAvatar(...),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Get.back();
        },
      ),
    );
  }

  Widget _buildConnectionStatusSubtitle(WebSocketStatus status) {
    switch (status) {
      case WebSocketStatus.connecting:
        return Text(
          "Connecting...",
          style: TextStyle(fontSize: 12, color: Colors.white70),
        );
      case WebSocketStatus.connected:
        // Bağlantı başarılı olduğunda "Online" yazabilir veya hiçbir şey göstermeyebilirsiniz.
        return Text(
          "Online",
          style: TextStyle(fontSize: 12, color: Colors.lightGreenAccent),
        );
      case WebSocketStatus.disconnected:
        return Text(
          "Disconnected. Trying to reconnect...",
          style: TextStyle(fontSize: 12, color: Colors.orange),
        );
      case WebSocketStatus.error:
        return Text(
          "Connection Error",
          style: TextStyle(fontSize: 12, color: Colors.redAccent),
        );
      default:
        return SizedBox.shrink(); // Hiçbir şey gösterme
    }
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            if (controller.replyingToMessage.value != null) {
              return ReplyPreviewWidget(
                message: controller.replyingToMessage.value!,
                onCancelReply: () => controller.cancelReply(),
              );
            }
            return SizedBox.shrink();
          }),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () => controller.sendMessage(conversationId: widget.conversation!.id, controller: _messageController),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReplyPreviewWidget extends StatelessWidget {
  final Message message;
  final VoidCallback onCancelReply;

  const ReplyPreviewWidget({
    Key? key,
    required this.message,
    required this.onCancelReply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderId.toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                ),
                Text(
                  message.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20),
            onPressed: onCancelReply,
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const ChatBubble({Key? key, required this.message, required this.isMe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.replyToId != null) _buildRepliedMessage(context),
            Text(
              message.content,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepliedMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: isMe ? Colors.white70 : Theme.of(context).primaryColor,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.repliedMessageSender ?? 'User',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isMe ? Colors.white : Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 2),
          Text(
            message.repliedMessageContent ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isMe ? Colors.white.withOpacity(0.9) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
