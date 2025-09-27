import 'package:get/get.dart';
import 'package:jaytap/modules/home/service/home_service.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';

class RealtorProfileController extends GetxController {
  final HomeService _homeService = HomeService();

  var isLoading = true.obs;
  var properties = <PropertyModel>[].obs;

  Future<void> fetchProperties(int realtorId) async {
    try {
      isLoading(true);
      final propertyList = await _homeService.fetchUserProducts(realtorId);
      properties.assignAll(propertyList);
    } finally {
      isLoading(false);
    }
  }
}
