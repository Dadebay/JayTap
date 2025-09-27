import 'package:get/get.dart';
import 'package:jaytap/modules/chat/controllers/chat_controller.dart';
import 'package:jaytap/modules/favorites/controllers/favorites_controller.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';

import '../controllers/home_controller.dart';

class BottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<SearchControllerMine>(() => SearchControllerMine());
    Get.lazyPut<ChatController>(() => ChatController());
    Get.lazyPut<FavoritesController>(() => FavoritesController());
    Get.lazyPut<UserProfilController>(() => UserProfilController());
  }
}
