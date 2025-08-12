import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/views/house_details_view.dart';

import '../controllers/house_details_controller.dart';

class HouseDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HouseDetailsController>(
      () => HouseDetailsController(),
    );
  }
}
