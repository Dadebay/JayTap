import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/chat/views/chat_model.dart';
import 'package:jaytap/modules/chat/views/chat_profil_screen.dart';
import 'package:jaytap/shared/extensions/extensions.dart';

class ChatCardWidget extends StatelessWidget {
  final ChatModel student;
  final bool themeValue;

  const ChatCardWidget({
    Key? key,
    required this.student,
    required this.themeValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ChatScreen(user: student)),
      child: Container(
        margin: const EdgeInsets.only(top: 12, right: 14, left: 14),
        padding: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.greyColor.withOpacity(.2)))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: Image.asset(
                student.photo,
                fit: BoxFit.cover,
                width: 60,
                height: 60,
                alignment: Alignment.topCenter,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.username,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: themeValue ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      student.lastMessage,
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
            Text(
              '29 Iyun',
              style: TextStyle(
                color: context.greyColor.withOpacity(.6),
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
