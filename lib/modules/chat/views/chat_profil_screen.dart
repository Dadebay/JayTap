import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/chat/controllers/chat_controller.dart';
import 'package:jaytap/modules/chat/views/chat_model.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';
import 'package:jaytap/shared/widgets/adaptive_dialog.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  final Conversation? conversation;
  final ChatUser? userModel;
  const ChatScreen({Key? key, this.conversation, this.userModel})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController controller = Get.put<ChatController>(ChatController());
  final ScrollController _scrollController = ScrollController();
  final UserProfilController _userProfilController =
      Get.find<UserProfilController>();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getToken();
    controller.connectToChat(
        conversationId: widget.conversation!.id,
        friendId: widget.userModel!.id);
    _messageController.addListener(() {
      setState(() {});
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print("Reached the top, load more messages...");
      }
    });
  }

  getToken() async {
    final _token = await AuthStorage().token;
    print(_token);
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
      return Scaffold(
          resizeToAvoidBottomInset: true,
          body: CustomWidgets.emptyDataWithLottie(
              lottiePath: IconConstants.chatJson, makeBigger: true));
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: ColorConstants.kPrimaryColor2.withOpacity(.5),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: _buildDefaultAppBar(context),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                final messages =
                    controller.messagesMap[widget.conversation?.id];
                if (controller.isLoadingMessages[widget.conversation?.id] ==
                        true &&
                    (messages == null || messages.isEmpty)) {
                  return CustomWidgets.loader();
                }
                if (messages == null || messages.isEmpty) {
                  return CustomWidgets.emptyDataWithLottie(
                      lottiePath: IconConstants.chatJson, makeBigger: true);
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.all(8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe =
                        msg.senderId == _userProfilController.user.value!.id;

                    return Dismissible(
                      key: Key(msg.id.toString()),
                      direction: isMe
                          ? DismissDirection.horizontal
                          : DismissDirection.startToEnd,
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          controller.setReplyTo(msg);
                          return false;
                        } else if (direction == DismissDirection.endToStart) {
                          final bool? shouldDelete =
                              await showCupertinoDialog<bool>(
                            context: context,
                            builder: (context) => CupertinoTheme(
                              data: CupertinoTheme.of(context).copyWith(
                                brightness: Brightness.light,
                                scaffoldBackgroundColor: CupertinoColors.white,
                                barBackgroundColor: CupertinoColors.white,
                              ),
                              child: CupertinoAlertDialog(
                                title: Text('delete_message_title'.tr),
                                content: Text(
                                  'delete_message_content'.tr,
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    isDefaultAction: true,
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text('cancel_delete'.tr),
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text('delete_confirm'.tr),
                                  ),
                                ],
                              ),
                            ),
                          );

                          if (shouldDelete == true) {
                            await controller.deleteMessage(
                                msg.id, widget.conversation!.id);
                            return true;
                          }
                          return false;
                        }
                        return false;
                      },
                      background: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Icon(Icons.reply, color: Colors.grey),
                        ),
                      ),
                      secondaryBackground: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Icon(IconlyBold.delete, color: Colors.grey),
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
      ),
    );
  }

  AppBar _buildDefaultAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ColorConstants.kPrimaryColor2.withOpacity(.5),
      title: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userModel!.name),
            _buildConnectionStatusSubtitle(controller.connectionStatus.value),
          ],
        );
      }),
      leading: IconButton(
        icon: Icon(IconlyLight.arrowLeftCircle, color: Colors.black),
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
          "connecting".tr,
          style: TextStyle(fontSize: 12, color: Colors.white70),
        );
      case WebSocketStatus.connected:
        return Text(
          "connected".tr,
          style: TextStyle(fontSize: 12, color: Colors.lightGreenAccent),
        );
      case WebSocketStatus.disconnected:
        return Text(
          "disconnected".tr,
          style: TextStyle(fontSize: 12, color: Colors.black),
        );
      case WebSocketStatus.error:
        return Text(
          "error".tr,
          style: TextStyle(fontSize: 12, color: Colors.redAccent),
        );
      default:
        return SizedBox.shrink();
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        _messageController.text.trim().isEmpty
                            ? IconlyLight.send
                            : IconlyBold.send,
                        color: _messageController.text.trim().isEmpty
                            ? ColorConstants.greyColor
                            : ColorConstants.kPrimaryColor2,
                      ),
                      onPressed: () {
                        if (_messageController.text.trim().isNotEmpty) {
                          controller.sendMessage(
                              conversationId: widget.conversation!.id,
                              controller: _messageController);
                        }
                      },
                    ),
                    hintText: "tap_to_chat".tr,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200, width: 2)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200, width: 2)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            BorderSide(color: Colors.amber.shade200, width: 2)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                            color:
                                ColorConstants.kPrimaryColor2.withOpacity(.5),
                            width: 2)),
                  ),
                ),
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
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor),
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

  const ChatBubble({Key? key, required this.message, required this.isMe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isMe
              ? ColorConstants.kPrimaryColor2.withOpacity(.6)
              : Colors.grey.shade100,
          borderRadius: isMe
              ? BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16))
              : BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16)),
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
