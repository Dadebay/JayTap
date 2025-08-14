import 'package:get/get.dart';

import '../controllers/house_details_controller.dart';

class HouseDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HouseDetailsController>(
      () => HouseDetailsController(),
    );
  }
}
