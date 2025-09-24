import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:jaytap/core/init/theme_controller.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/auth/views/login_view.dart';
import 'package:jaytap/modules/chat/views/chat_model.dart';
import 'package:jaytap/modules/chat/views/chat_profil_screen.dart';
import 'package:jaytap/modules/user_profile/views/about_us_view.dart';
import 'package:jaytap/modules/user_profile/views/edit_profile_view.dart';
import 'package:jaytap/modules/user_profile/views/help_view.dart';
import 'package:jaytap/modules/user_profile/views/profile_button.dart';
import 'package:jaytap/shared/dialogs/dialogs_utils.dart';
import 'package:jaytap/shared/extensions/packages.dart';
import 'package:kartal/kartal.dart';
import '../controllers/user_profile_controller.dart';

class UserProfileView extends GetView<UserProfilController> {
  List<Map<String, dynamic>> _buildProfileItems(bool isLoggedIn, bool darkMode) {
    List<Map<String, dynamic>> items = [
      // {
      //   'name': darkMode ? 'darkMode' : 'lightMode',
      //   'icon': darkMode
      //       ? HugeIcons.strokeRoundedMoon02
      //       : HugeIcons.strokeRoundedSun01,
      //   'showOnLogin': true,
      //   'onTap': () {
      //     final themeController = Get.find<ThemeController>();
      //     themeController.toggleTheme();
      //   }
      // },
      {'name': 'language', 'showOnLogin': false, 'icon': HugeIcons.strokeRoundedLanguageSquare, 'onTap': () => DialogUtils().changeLanguage(Get.context!)},
      {
        'name': 'chat',
        'showOnLogin': false,
        'icon': IconlyLight.chat,
        'onTap': () {
          final adminId = controller.user.value?.adminId ?? 1;
          Get.to(() => ChatScreen(
                conversation: Conversation(
                  id: adminId,
                  createdAt: DateTime.now(),
                ),
                userModel: ChatUser(id: adminId, username: "Admin", name: "Admin", blok: false, rating: "0.0", productCount: 0, premiumCount: 0, viewCount: 0),
              ));
        }
      },
      {'name': 'helpApp', 'showOnLogin': false, 'icon': HugeIcons.strokeRoundedInformationCircle, 'onTap': () => Get.to(() => HelpView())},
      {'name': 'aboutUs', 'showOnLogin': false, 'icon': HugeIcons.strokeRoundedHelpSquare, 'onTap': () => Get.to(() => AboutUsView())},
    ];
    if (isLoggedIn) {
      items.insert(0, {'name': 'user_profile', 'showOnLogin': false, 'icon': HugeIcons.strokeRoundedEdit01, 'onTap': () => Get.to(() => EditProfileView())});
    }
    if (isLoggedIn) {
      items.add({
        'name': 'logout',
        'icon': IconlyLight.logout,
        'onTap': () {
          DialogUtils().logOut(Get.context!);
        },
      });
    } else {
      items.add({
        'name': 'signUp',
        'icon': IconlyLight.login,
        'onTap': () => Get.to(() => LoginView()),
      });
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final authStorage = AuthStorage();
    final bool isLoggedIn = authStorage.isLoggedIn;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> profilePageIcons = _buildProfileItems(isLoggedIn, isDarkMode);

    return Padding(
      padding: context.padding.onlyTopNormal,
      child: ListView.separated(
        itemCount: profilePageIcons.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return ProfilButton(
            name: profilePageIcons[index]['name'].toString(),
            icon: profilePageIcons[index]['icon'] as IconData,
            onTap: profilePageIcons[index]['onTap'] as VoidCallback,
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
              child: Divider(
                color: Colors.grey.shade200,
              ));
        },
      ),
    );
  }
}
