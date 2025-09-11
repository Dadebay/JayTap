// ignore_for_file: deprecated_member_use
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/chat/widgets/chat_card_widget.dart';
import 'package:jaytap/shared/extensions/packages.dart';
import 'package:kartal/kartal.dart';
import 'package:lottie/lottie.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  ChatView({super.key});

  OutlineInputBorder _buildOutlineInputBorder(BuildContext context,
      {Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
          color: borderColor ?? Theme.of(context).colorScheme.outline,
          width: 2),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie/Chat.json', height: 250),
            const SizedBox(height: 20),
            Text(
              'login_to_chat'.tr,
              style: context.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'login_to_chat_subtitle'.tr,
              style: context.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(ChatController());
    if (!AuthStorage().isLoggedIn) {
      return _buildNotLoggedIn(context);
    }

    bool themeValue =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: TextFormField(
            style: context.general.textTheme.bodyLarge!
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
            controller: _searchController,
            onChanged: (value) {
              _searchQuery.value = value;
            },
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Icon(
                  IconlyLight.search,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20.sp,
                ),
              ),
              hintText: "${"search".tr}...",
              fillColor: Theme.of(context).colorScheme.surfaceVariant,
              filled: true,
              hintStyle: context.general.textTheme.bodyLarge!
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
              contentPadding: const EdgeInsets.only(
                  left: 16, top: 14, bottom: 14, right: 10),
              isDense: true,
              border: _buildOutlineInputBorder(context),
              enabledBorder: _buildOutlineInputBorder(context),
              focusedBorder: _buildOutlineInputBorder(context),
            ),
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.conversations.isEmpty &&
                controller.isLoading.isTrue) {
              return CustomWidgets.loader();
            } else if (controller.conversations.isEmpty) {
              return CustomWidgets.loader();
            }

            final allConversations = controller.conversations;
            final filteredConversations = allConversations.where((conv) {
              final query = _searchQuery.value.toLowerCase();
              final userName = conv.friend?.name.toLowerCase() ?? '';
              return userName.contains(query);
            }).toList();

            if (filteredConversations.isEmpty) {
              return CustomWidgets.loader();
            }

            return ListView.builder(
              itemCount: filteredConversations.length,
              itemExtent: 90,
              itemBuilder: (context, index) {
                final conversation = filteredConversations[index];
                return ChatCardWidget(
                  conversation: conversation,
                  themeValue: themeValue,
                  chatUser: conversation.friend!,
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
