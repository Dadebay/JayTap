import 'package:get/get.dart';
import 'package:jaytap/modules/related_houses/controllers/related_houses_controller.dart';

class RelatedHousesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RelatedHousesController>(
      () => RelatedHousesController(),
    );
  }
}
