import 'package:get/get.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchControllerMine>(
      () => SearchControllerMine(),
    );
  }
}
