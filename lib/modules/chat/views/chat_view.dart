import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/chat/views/chat_model.dart';
import 'package:jaytap/modules/chat/widgets/chat_card_widget.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:kartal/kartal.dart';

import '../controllers/chat_controller.dart';

class ChatView extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());
  OutlineInputBorder _buildOutlineInputBorder({Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: borderColor ?? Colors.grey, width: 2),
    );
  }

  final TextEditingController _messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    bool themeValue = Theme.of(context).brightness == Brightness.dark ? true : false;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: TextFormField(
            style: context.general.textTheme.bodyLarge!.copyWith(color: context.blackColor),
            controller: _messageController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'textfield_error'.tr;
              }
              return null;
            },
            onEditingComplete: () {},
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              prefixIconConstraints: BoxConstraints(minWidth: 20, minHeight: 0),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Icon(
                  IconlyLight.search,
                  color: ColorConstants.greyColor,
                  size: 20.sp,
                ),
              ),
              hintText: "search".tr + "...",
              fillColor: Color(0xffF6F6F6),
              filled: true,
              hintStyle: context.general.textTheme.bodyLarge!.copyWith(color: context.blackColor),
              floatingLabelAlignment: FloatingLabelAlignment.start,
              contentPadding: const EdgeInsets.only(left: 16, top: 14, bottom: 14, right: 10),
              isDense: true,
              alignLabelWithHint: true,
              border: _buildOutlineInputBorder(borderColor: ColorConstants.blackColor),
              enabledBorder: OutlineInputBorder(
                borderRadius: context.border.highBorderRadius,
                borderSide: BorderSide(color: Color(0xffF6F6F6), width: 2),
              ),
              focusedBorder: _buildOutlineInputBorder(borderColor: context.blackColor),
              focusedErrorBorder: _buildOutlineInputBorder(borderColor: ColorConstants.redColor),
              errorBorder: _buildOutlineInputBorder(borderColor: ColorConstants.redColor),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Conversation>>(
            future: controller.fetchConversations(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No conversations found."));
              }

              final conversations = snapshot.data!;
              return ListView.builder(
                itemCount: conversations.length,
                itemExtent: 90, // Consider making this dynamic
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  return ChatCardWidget(
                    conversation: conversation,
                    themeValue: themeValue,
                    chatUser: conversation.friend!,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
