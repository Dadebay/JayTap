import 'package:get/get.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<SearchControllerMine>(
      () => SearchControllerMine(),
    );
  }
}
