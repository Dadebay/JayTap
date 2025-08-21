import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/chat/views/chat_model.dart';
import 'package:jaytap/modules/chat/views/chat_profil_screen.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:intl/intl.dart';

class ChatCardWidget extends StatelessWidget {
  final Conversation conversation;
  final ChatUser chatUser;

  final bool themeValue;

  const ChatCardWidget({
    Key? key,
    required this.conversation,
    required this.themeValue,
    required this.chatUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lastMessageText = conversation.lastMessage.isNotEmpty ? conversation.lastMessage : "Tap to chat...";

    return GestureDetector(
      onTap: () {
        Get.to(() => ChatScreen(conversation: conversation, userModel: chatUser));
      },
      child: Container(
        margin: const EdgeInsets.only(top: 12, right: 14, left: 14),
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: context.greyColor.withOpacity(.2))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(chatUser.imgUrl ?? 'https://i.pravatar.cc/150?img=12'),
              onBackgroundImageError: (_, __) {},
              backgroundColor: Colors.grey.shade300,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      chatUser.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: themeValue ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessageText,
                      style: TextStyle(
                        color: context.greyColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat.jm().format(conversation.createdAt.toLocal()),
                  style: TextStyle(
                    color: context.greyColor.withOpacity(.6),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
