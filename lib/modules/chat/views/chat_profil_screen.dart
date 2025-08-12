import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:kartal/kartal.dart';

import '../controllers/chat_controller.dart';
import '../views/chat_model.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final ChatModel user;
  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController controller = Get.find<ChatController>();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listener to sync text field controller with GetX controller
    _textController.addListener(() {
      controller.messageText.value = _textController.text;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure messages for the user are loaded
    if (!controller.messagesMap.containsKey(widget.user.id)) {
      controller.messagesMap[widget.user.id] = <Message>[].obs;
    }
    final messages = controller.messagesMap[widget.user.id]!;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == controller.myUserId;
                    final isSelected = controller.selectedMessages.contains(msg.id);

                    return GestureDetector(
                      onLongPress: () => controller.onMessageLongPress(msg.id),
                      onTap: () {
                        if (controller.isSelectionMode.value) {
                          controller.toggleMessageSelection(msg.id);
                        }
                      },
                      child: Container(
                        color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
                        child: ChatBubble(
                          message: msg,
                          isMe: isMe,
                        ),
                      ),
                    );
                  },
                )),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(70.0),
      child: Obx(() => controller.isSelectionMode.value ? _buildSelectionAppBar(context) : _buildDefaultAppBar(context)),
    );
  }

  AppBar _buildDefaultAppBar(BuildContext context) {
    return AppBar(
      elevation: 2,
      toolbarHeight: 70,
      scrolledUnderElevation: 2,
      shadowColor: context.greyColor.withOpacity(.3),
      leading: IconButton(
        icon: Icon(IconlyLight.arrowLeftCircle, color: context.greyColor),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          ClipOval(
            child: Image.asset(
              widget.user.photo,
              fit: BoxFit.cover,
              width: 50,
              height: 50,
              alignment: Alignment.topCenter,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.username,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Online',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBar _buildSelectionAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: controller.cancelSelection,
      ),
      title: Obx(() => Text('${controller.selectedMessages.length} selected')),
      actions: [
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => controller.deleteSelectedMessages(widget.user.id),
        ),
      ],
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      margin: context.padding.normal.copyWith(bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.greyColor.withOpacity(.15),
        borderRadius: context.border.normalBorderRadius,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Type a message",
                hintStyle: TextStyle(color: context.greyColor.withOpacity(.6), fontWeight: FontWeight.w400),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
              ),
            ),
          ),
          Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(child: child, scale: animation);
                },
                child: controller.messageText.value.isEmpty
                    ? IconButton(
                        key: ValueKey('camera_button'),
                        icon: Icon(CupertinoIcons.add_circled, color: context.greyColor.withOpacity(.6)),
                        onPressed: () => controller.sendImage(widget.user.id),
                      )
                    : IconButton(
                        key: ValueKey('send_button'),
                        icon: Icon(IconlyBold.send, color: Theme.of(context).primaryColor),
                        onPressed: () {
                          if (controller.messageText.isNotEmpty) {
                            controller.sendMessage(widget.user.id);
                            _textController.clear();
                          }
                        },
                      ),
              )),
        ],
      ),
    );
  }
}
