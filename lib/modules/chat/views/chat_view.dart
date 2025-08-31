import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/chat/views/chat_model.dart';
import 'package:jaytap/modules/chat/widgets/chat_card_widget.dart';
import 'package:jaytap/shared/extensions/packages.dart';
import 'package:kartal/kartal.dart';
import 'package:lottie/lottie.dart';
import '../controllers/chat_controller.dart';

class ChatView extends StatefulWidget {
  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final ChatController controller = Get.put(ChatController());
  final TextEditingController _messageController = TextEditingController();
  List<Conversation> _allConversations = [];
  List<Conversation> _filteredConversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (AuthStorage().isLoggedIn) {
      controller.fetchConversations().then((conversations) {
        setState(() {
          _allConversations = conversations;
          _filteredConversations = conversations;
          _isLoading = false;
        });
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
    _messageController.addListener(() {
      filterConversations();
    });
  }

  void filterConversations() {
    final query = _messageController.text.toLowerCase();
    setState(() {
      _filteredConversations = _allConversations.where((conv) {
        final userName = conv.friend?.name?.toLowerCase() ?? '';
        return userName.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  OutlineInputBorder _buildOutlineInputBorder({Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: borderColor ?? Colors.grey, width: 2),
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
            SizedBox(height: 20),
            Text(
              'login_to_chat'.tr,
              style: context.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
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
                .copyWith(color: context.blackColor),
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
              hintStyle: context.general.textTheme.bodyLarge!
                  .copyWith(color: context.blackColor),
              floatingLabelAlignment: FloatingLabelAlignment.start,
              contentPadding: const EdgeInsets.only(
                  left: 16, top: 14, bottom: 14, right: 10),
              isDense: true,
              alignLabelWithHint: true,
              border: _buildOutlineInputBorder(
                  borderColor: ColorConstants.blackColor),
              enabledBorder: OutlineInputBorder(
                borderRadius: context.border.normalBorderRadius,
                borderSide: BorderSide(color: Color(0xffF6F6F6), width: 2),
              ),
              focusedBorder:
                  _buildOutlineInputBorder(borderColor: context.blackColor),
              focusedErrorBorder: _buildOutlineInputBorder(
                  borderColor: ColorConstants.redColor),
              errorBorder: _buildOutlineInputBorder(
                  borderColor: ColorConstants.redColor),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? CustomWidgets.loader()
              : _filteredConversations.isEmpty
                  ? Center(child: Text('no_chats_found'.tr))
                  : ListView.builder(
                      itemCount: _filteredConversations.length,
                      itemExtent: 90,
                      itemBuilder: (context, index) {
                        final conversation = _filteredConversations[index];
                        return ChatCardWidget(
                          conversation: conversation,
                          themeValue: themeValue,
                          chatUser: conversation.friend!,
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
