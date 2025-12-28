import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
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

class ProfileItem {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  ProfileItem({required this.name, required this.icon, required this.onTap});
}

List<ProfileItem> _buildProfileItems(
  BuildContext context,
  UserProfilController controller,
  bool isLoggedIn,
) {
  return [
    if (isLoggedIn)
      ProfileItem(
        name: 'user_profile',
        icon: HugeIcons.strokeRoundedEdit01,
        onTap: () => Get.to(() => EditProfileView()),
      ),
    ProfileItem(
      name: 'language',
      icon: HugeIcons.strokeRoundedLanguageSquare,
      onTap: () => DialogUtils().changeLanguage(context),
    ),
    ProfileItem(
      name: 'chat',
      icon: IconlyLight.chat,
      onTap: () {
        final adminId = controller.user.value?.adminId ?? 1;
        Get.to(() => ChatScreen(
              conversation: Conversation(
                id: adminId,
                createdAt: DateTime.now(),
              ),
              userModel: ChatUser(
                  id: adminId,
                  username: "Admin",
                  name: "Admin",
                  blok: false,
                  rating: "0.0",
                  productCount: 0,
                  premiumCount: 0,
                  viewCount: 0),
            ));
      },
    ),
    ProfileItem(
      name: 'helpApp',
      icon: HugeIcons.strokeRoundedInformationCircle,
      onTap: () => Get.to(() => HelpView()),
    ),
    ProfileItem(
      name: 'aboutUs',
      icon: HugeIcons.strokeRoundedHelpSquare,
      onTap: () => Get.to(() => AboutUsView()),
    ),
    if (isLoggedIn)
      ProfileItem(
        name: 'logout',
        icon: IconlyLight.logout,
        onTap: () => DialogUtils().logOut(context),
      )
    else
      ProfileItem(
        name: 'signUp',
        icon: IconlyLight.login,
        onTap: () => Get.to(() => LoginView()),
      ),
  ];
}

class UserProfileView extends GetView<UserProfilController> {
  @override
  Widget build(BuildContext context) {
    final authStorage = AuthStorage();
    final bool isLoggedIn = authStorage.isLoggedIn;
    final profileItems = _buildProfileItems(context, controller, isLoggedIn);

    return Padding(
      padding: context.padding.onlyTopNormal,
      child: ListView.separated(
        itemCount: profileItems.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final item = profileItems[index];
          return ProfilButton(
            name: item.name,
            icon: item.icon,
            onTap: item.onTap,
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 2),
            child: Divider(
              color: Colors.grey.shade200,
            ),
          );
        },
      ),
    );
  }
}