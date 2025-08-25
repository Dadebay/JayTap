import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/house_details_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/connection_check_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/favorites/bindings/favorites_binding.dart';
import '../modules/favorites/views/favorites_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/bottom_nav_bar_view.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home/views/pages/notifications_view.dart';
import '../modules/house_details/bindings/house_details_binding.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/user_profile/bindings/user_profile_binding.dart';
import '../modules/user_profile/views/user_profile_view.dart';

import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.FAVORITES,
      page: () => const FavoritesView(),
      binding: FavoritesBinding(),
    ),
    GetPage(
      name: Routes.SEARCH_VIEW,
      page: () =>  SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: Routes.USER_PROFILE,
      page: () => UserProfileView(),
      binding: UserProfileBinding(),
    ),
    GetPage(
      name: Routes.AUTH,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.CONNECTIONCHECKVIEW,
      page: () => ConnectionCheckView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.NOTIFICATIONVIEW,
      page: () => NotificationsView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.BOTTOMNAVBAR,
      page: () => BottomNavBar(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.CHAT,
      page: () => ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: Routes.HOUSE_DETAILS,
      page: () => HouseDetailsView(
        houseID: 0,
        myHouses: false,
      ),
      binding: HouseDetailsBinding(),
    ),
  ];
}
