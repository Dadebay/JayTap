// ignore_for_file: deprecated_member_use
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/chat/widgets/chat_card_widget.dart';
import 'package:jaytap/shared/extensions/packages.dart';
import 'package:kartal/kartal.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart'; // Import Get for Get.find
import '../controllers/chat_controller.dart';
import '../views/chat_service.dart'; // Import ChatService
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart'; // Import UserProfilController

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final ChatService _chatService = ChatService();
  final AuthStorage _authStorage = AuthStorage();
  late final ChatController controller;
  final userProfilController = Get.find<UserProfilController>();
  @override
  void initState() {
    super.initState();
    print("ChatView: initState called.");
    controller = Get.find<ChatController>();

    _initializeChatConnection();
  }

  Future<void> _initializeChatConnection() async {
    print("ChatView: AuthStorage.isLoggedIn = ${_authStorage.isLoggedIn}");

    if (_authStorage.isLoggedIn) {
      await userProfilController.fetchUserData();

      if (userProfilController.user.value != null) {
        _chatService.connectGlobalChat(
          myId: userProfilController.user.value!.id,
          onNewMessage: (data) {
            print("ChatView: Global WebSocket - New Message Received: $data");

            controller.handleGlobalConversationUpdate(data);
          },
          onStatusChanged: (status) {
            print(
                "ChatView: Global WebSocket Status Changed from ChatView: $status");
          },
        );
      }
    }

    await controller.fetchConversations(showLoading: false);
  }

  @override
  void dispose() {
    print("ChatView: dispose called. Disconnecting global chat.");
    _chatService.disconnectGlobalChat();
    _searchController.dispose();
    _searchQuery.close();
    super.dispose();
  }

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
    if (!_authStorage.isLoggedIn) {
      // Use _authStorage instance
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
            // Access controller via the instance
            if (controller.isLoading.isTrue) {
              return CustomWidgets.loader();
            } else if (controller.conversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/lottie/Chat.json', height: 250),
                    const SizedBox(height: 20),
                    Text(
                      'no_conversations_found'.tr,
                      style: context.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'start_a_new_chat'.tr,
                      style: context.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
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
                final friend = conversation.friend!;
                controller.newMessageForConversation.contains(conversation.id);
                return ChatCardWidget(
                  conversation: conversation,
                  themeValue: themeValue,
                  chatUser: friend,
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
