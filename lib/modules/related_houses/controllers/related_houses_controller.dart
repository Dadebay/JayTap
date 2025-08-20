import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart'; // Assuming PropertyModel is used for houses
import 'package:jaytap/modules/search/service/filter_service.dart'; // Re-using FilterService for fetching houses

class RelatedHousesController extends GetxController {
  final FilterService _filterService = FilterService();
  final isLoading = true.obs;
  final houses = <PropertyModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic>? args = Get.arguments;
    if (args != null && args.containsKey('filteredIds')) {
      final List<int> filteredIds = List<int>.from(args['filteredIds']);
      if (filteredIds.isNotEmpty) {
        // Assuming the API expects a comma-separated string of IDs
        final String idsString = filteredIds.join(',');
        fetchHouses({'ids': idsString});
      } else {
        isLoading.value = false;
        Get.snackbar('Info', 'No properties found for the selected filters.');
      }
    } else {
      // If no filter data is provided, fetch all houses or handle as per app logic
      // For now, let's just show a message or fetch all if that's the default behavior
      isLoading.value = false;
      Get.snackbar('Error', 'No filter data provided. Displaying all houses (if applicable).');
      // You might want to call a method here to fetch all houses if that's the desired fallback
    }
  }

  Future<void> fetchHouses(Map<String, dynamic> filterData) async {
    try {
      isLoading.value = true;

      final fetchedHouses = await _filterService.fetchHousesByFilter(filterData);
      houses.value = fetchedHouses;

    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch houses: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
