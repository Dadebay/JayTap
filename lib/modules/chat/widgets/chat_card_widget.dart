import 'package:jaytap/modules/chat/controllers/chat_controller.dart';
import 'package:jaytap/modules/chat/views/chat_model.dart';
import 'package:jaytap/modules/chat/views/chat_profil_screen.dart';
import 'package:intl/intl.dart';
import 'package:jaytap/shared/extensions/packages.dart';

class ChatCardWidget extends StatelessWidget {
  final Conversation conversation;
  final ChatUser chatUser;
  final bool themeValue;

  ChatCardWidget({
    Key? key,
    required this.conversation,
    required this.themeValue,
    required this.chatUser,
  }) : super(key: key);

  final ChatController controller = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    final lastMessageText = conversation.lastMessage.isNotEmpty
        ? conversation.lastMessage
        : "tap_to_chat".tr;

    return Obx(() {
      final isNewMessage =
          controller.newMessageForConversation.contains(conversation.id);

      return GestureDetector(
        onTap: () {
          controller.newMessageForConversation.remove(conversation.id);
          Get.to(
            () => ChatScreen(conversation: conversation, userModel: chatUser),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(top: 12, right: 14, left: 14),
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: context.greyColor.withOpacity(.2)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  ClipOval(
                    child: Container(
                      width: 65,
                      height: 65,
                      child: CachedNetworkImage(
                        imageUrl: chatUser.imgUrl ?? '',
                        width: Get.size.width,
                        imageBuilder: (context, imageProvider) => Container(
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        alignment: Alignment.bottomCenter,
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
                  const SizedBox(height: 6),
                  if (isNewMessage)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
