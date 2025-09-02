import 'package:get/get.dart';
import 'package:jaytap/modules/chat/controllers/chat_controller.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    // Get.lazyPut<ChatController>(
    //   () => ChatController(),
    // );
  }
}
