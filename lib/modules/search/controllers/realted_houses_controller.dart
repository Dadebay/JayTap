import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/service/property_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RealtedHousesController extends GetxController {
  final PropertyService _propertyService = PropertyService();

  var isLoading = true.obs;
  var properties = <PropertyModel>[].obs;
  var currentPage = 1.obs;
  var hasNextPage = true.obs;
  var isGridView = true.obs;

  final RefreshController refreshController = RefreshController();

  Future<void> fetchPropertiesByIds(
      {required bool isRefresh, required List<int> propertyIds}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasNextPage.value = true;
    }

    if (!hasNextPage.value && !isRefresh) {
      refreshController.loadNoData();
      return;
    }

    try {
      if (isRefresh && properties.isEmpty) {
        isLoading.value = true;
      }

      final response = await _propertyService.fetchPropertiesByIds(
        propertyIds: propertyIds,
        page: currentPage.value,
        pageSize: 10,
      );

      if (isRefresh) {
        properties.clear();
      }
      properties.addAll(response.cast<PropertyModel>());
      hasNextPage.value = response.length == 10;
      if (hasNextPage.value) {
        currentPage.value++;
      }
    } catch (e) {
      Get.snackbar('Hata', 'İlanlar yüklenirken bir sorun oluştu.');
    } finally {
      if (isRefresh) {
        refreshController.refreshCompleted();
      } else {
        refreshController.loadComplete();
      }

      if (!hasNextPage.value) {
        refreshController.loadNoData();
      }

      isLoading.value = false;
    }
  }

  void toggleView() {
    isGridView.value = !isGridView.value;
  }

  void setProperties(List<PropertyModel> newProperties) {
    isLoading.value = true;
    properties.assignAll(newProperties);
    hasNextPage.value = false;
    isLoading.value = false;
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
