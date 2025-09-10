import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/favorites/controllers/favorites_controller.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/service/add_house_service.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';
import 'package:jaytap/modules/search/service/filter_service.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

class FilterController extends GetxController {
  final AddHouseService _addHouseService = AddHouseService();
  final FilterService _filterService =
      FilterService(); // Instantiate the new service

  // --- UI STATE ---
  final isLoading = true.obs;

  // --- FORM DATA ---
  // Location
  final villages = <Village>[].obs;
  final regions = <Village>[].obs;
  final selectedVillageId = Rxn<int>();
  final selectedRegionId = Rxn<int>();

  // Categories
  final categories = <Category>[].obs;
  final subCategories = <SubCategory>[].obs;
  final subinCategories = <SubCategory>[].obs;
  final selectedCategoryId = Rxn<int>();
  final selectedSubCategoryId = Rxn<int>();
  final selectedInSubCategoryId = Rxn<int>();

  // Property Details
  final totalFloorCount = <int>[].obs;
  final selectedBuildingFloor = <int>[].obs;
  final totalRoomCount = <int>[].obs;

  // Specifications
  final specifications = <Specification>[].obs;
  final specificationCounts = <int, RxInt>{}.obs;

  // Renovation
  final remontOptions = <RemontOption>[].obs;
  final selectedRenovation = Rxn<String>();
  final selectedRenovationId = Rxn<int>();

  // Extra Information
  final extrainforms = <Extrainform>[].obs;

  // Spheres
  final spheres = <Sphere>[].obs;
  final selectedSpheres = <Sphere>[].obs;

  // Seller Type
  final sellerType = Rxn<String>();

  // Limits
  LimitData? limits;
  final minRoom = Rxn<int>();
  final maxRoom = Rxn<int>();
  final minFloor = Rxn<int>();
  final maxFloor = Rxn<int>();

  // Price Controllers
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();

  // Area Controllers
  final minAreaController = TextEditingController();
  final maxAreaController = TextEditingController();
  final selectedAreaRange = const RangeValues(0, 0).obs;

  @override
  void onInit() {
    super.onInit();
    initialize();
    updateAreaTextFields(selectedAreaRange.value);
    minAreaController.addListener(_onMinAreaChanged);
    maxAreaController.addListener(_onMaxAreaChanged);
  }

  Future<void> initialize() async {
    isLoading.value = true;
    await Future.wait([
      fetchInitialData(),
      _fetchLimits(),
      _fetchSpecifications(),
      _fetchRemontOptions(),
      _fetchExtrainforms(),
      _fetchSpheres(),
    ]);
    isLoading.value = false;
  }

  // --- AREA SLIDER AND TEXTFIELD LOGIC ---
  void updateAreaRange(RangeValues values) {
    selectedAreaRange.value = values;
    updateAreaTextFields(values);
  }

  void updateAreaTextFields(RangeValues values) {
    final start = values.start.round().toString();
    final end = values.end.round().toString();
    if (minAreaController.text != start) {
      minAreaController.text = start;
    }
    if (maxAreaController.text != end) {
      maxAreaController.text = end;
    }
  }

  void _onMinAreaChanged() {
    final minVal = double.tryParse(minAreaController.text);
    if (minVal != null &&
        minVal >= 0 &&
        minVal <= selectedAreaRange.value.end) {
      if (minVal != selectedAreaRange.value.start) {
        selectedAreaRange.value =
            RangeValues(minVal, selectedAreaRange.value.end);
      }
    } else if (minAreaController.text.isNotEmpty) {
      // Handle invalid input if needed, e.g., reset to the last valid value
    }
  }

  void _onMaxAreaChanged() {
    final maxVal = double.tryParse(maxAreaController.text);
    if (maxVal != null &&
        maxVal >= selectedAreaRange.value.start &&
        maxVal <= 1000) {
      // Assuming 1000 is the max limit
      if (maxVal != selectedAreaRange.value.end) {
        selectedAreaRange.value =
            RangeValues(selectedAreaRange.value.start, maxVal);
      }
    } else if (maxAreaController.text.isNotEmpty) {
      // Handle invalid input
    }
  }

  // --- DATA FETCHING ---
  Future<void> fetchInitialData() async {
    final fetchedVillages = await _addHouseService.fetchVillages();
    if (fetchedVillages.isNotEmpty) {
      villages.value = fetchedVillages;
    }
    await fetchCategories();
  }

  Future<void> fetchCategories() async {
    final fetchedCategories = await _addHouseService.fetchCategories();
    if (fetchedCategories.isNotEmpty) {
      categories.value = fetchedCategories;
    }
  }

  Future<void> fetchRegions(int villageId) async {
    regions.clear();
    selectedRegionId.value = null; // Set to null for no selection
    final fetchedRegions = await _addHouseService.fetchRegions(villageId);
    if (fetchedRegions.isNotEmpty) {
      regions.value = fetchedRegions;
    }
  }

  Future<void> _fetchLimits() async {
    limits = await _addHouseService.fetchLimits();
    if (limits != null) {
      minRoom.value = limits!.minRoom;
      maxRoom.value = limits!.maxRoom;
      minFloor.value = limits!.minFloor;
      maxFloor.value = limits!.maxFloor;
    }
  }

  Future<void> _fetchSpecifications() async {
    final fetchedSpecifications = await _addHouseService.fetchSpecifications();
    if (fetchedSpecifications.isNotEmpty) {
      specifications.value = fetchedSpecifications;
      for (var spec in fetchedSpecifications) {
        specificationCounts[spec.id] = 0.obs;
      }
    }
  }

  Future<void> _fetchRemontOptions() async {
    remontOptions.value = await _addHouseService.fetchRemontOptions();
  }

  Future<void> _fetchExtrainforms() async {
    extrainforms.value = await _addHouseService.fetchExtrainforms();
  }

  Future<void> _fetchSpheres() async {
    spheres.value = await _addHouseService.fetchSpheres();
  }

  // --- FORM SELECTION HANDLERS ---
  void selectSellerType(String type) {
    sellerType.value = type;
  }

  void selectVillage(int villageId) {
    selectedVillageId.value = villageId;
    fetchRegions(villageId);
  }

  void selectRegion(int regionId) {
    selectedRegionId.value = regionId;
  }

  void selectCategory(int categoryId) {
    selectedCategoryId.value = categoryId;
    final selectedCategory = categories.firstWhere((c) => c.id == categoryId);
    subCategories.value = selectedCategory.subcategory;
    selectedSubCategoryId.value = null; // Set to null for no selection
  }

  void selectSubCategory(int subCategoryId) {
    selectedSubCategoryId.value = subCategoryId;
    final selectedSubCategory =
        subCategories.firstWhere((sc) => sc.id == subCategoryId);
    subinCategories.value = selectedSubCategory.subin ?? [];
    selectedInSubCategoryId.value = null; // Set to null for no selection
  }

  void selectSubIncategory(int subInCategoryId) {
    selectedInSubCategoryId.value = subInCategoryId;
  }

  void toggleBuildingFloor(int floor) {
    if (selectedBuildingFloor.contains(floor)) {
      selectedBuildingFloor.remove(floor);
    } else {
      selectedBuildingFloor.add(floor);
    }
  }

  void toggleTotalFloor(int floor) {
    if (totalFloorCount.contains(floor)) {
      totalFloorCount.remove(floor);
    } else {
      totalFloorCount.add(floor);
    }
  }

  void toggleRoomCount(int count) {
    if (totalRoomCount.contains(count)) {
      totalRoomCount.remove(count);
    } else {
      totalRoomCount.add(count);
    }
  }

  void selectRenovation(int id, String name) {
    selectedRenovationId.value = id;
    selectedRenovation.value = name;
  }

  void changeSpecificationCount(int specificationId, int change) {
    final currentCount = specificationCounts[specificationId]!.value;
    if (currentCount + change >= 0) {
      specificationCounts[specificationId]!.value += change;
    }
  }

  // --- SUBMISSION ---
  Future<void> applyFilters() async {
    try {
      isLoading.value = true;

      final filterData = <String, dynamic>{
        'category_id': selectedCategoryId.value,
        'subcat_id': selectedSubCategoryId.value,
        'subincat_id': selectedInSubCategoryId.value,
        'village_id': selectedVillageId.value,
        'floorcount': selectedBuildingFloor.join(','),
        'totalfloorcount': totalFloorCount.join(','),
        'roomcount': totalRoomCount.join(','),
        'minsquare': (double.tryParse(minAreaController.text) ?? 0).toInt(),
        'maxsquare': (double.tryParse(maxAreaController.text) ?? 0).toInt(),
        'remont_id': selectedRenovationId.value,
        'owner': sellerType.value == 'Eýesi'
            ? 1
            : (sellerType.value == 'Reiltor' ? 4 : null),
        'maxprice': double.tryParse(maxPriceController.text),
        'minprice': double.tryParse(minPriceController.text),
      };

      filterData.removeWhere((key, value) => value == null);

      print('Sending filter data to API: $filterData');

      final HomeController homeController = Get.find();
      final List<MapPropertyModel> fetchedFilteredProperties =
          await _filterService.searchProperties(filterData);
      homeController.shouldFetchAllProperties.value = false;

      final List<int> propertyIds =
          fetchedFilteredProperties.map((p) => p.id).toList();
      final SearchControllerMine searchController =
          Get.find<SearchControllerMine>();
      searchController.loadPropertiesByIds(propertyIds);
      Get.back();
      homeController.changePage(1);
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveFilters(String name) async {
    try {
      isLoading.value = true;

      final filterData = <String, dynamic>{
        'name': name,
        'category_id': selectedCategoryId.value,
        'subcat_id': selectedSubCategoryId.value,
        'subincat_id': selectedInSubCategoryId.value,
        'village_id':
            selectedVillageId.value == 0 ? null : selectedVillageId.value,
        'floorcount': selectedBuildingFloor.join(','),
        'totalfloorcount': totalFloorCount.join(','),
        'roomcount': totalRoomCount.join(','),
        'minsquare': (double.tryParse(minAreaController.text) ?? 0).toInt(),
        'maxsquare': (double.tryParse(maxAreaController.text) ?? 0).toInt(),
        'remont_id': selectedRenovationId.value == null
            ? null
            : selectedRenovationId.value,
        'owner': sellerType.value == 'Eýesi'
            ? 1
            : (sellerType.value == 'realtor' ? 0 : null),
        'maxprice': double.tryParse(maxPriceController.text) ?? 0.0,
        'minprice': double.tryParse(minPriceController.text) ?? 0.0,
      };

      filterData.removeWhere((key, value) => value == null);

      await _filterService.saveFilters(filterData);
      Get.back();
      _showSuccessSnackbar('filters_saved_successfully'.tr);

      final FavoritesController favoritesController =
          Get.find<FavoritesController>();
      favoritesController.fetchAndDisplayFilterDetails();
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  void showSaveFilterDialog() {
    final TextEditingController nameController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Text('save'.tr),
          ],
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'enter_filter_name'.tr,
            prefixIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedEdit01,
              size: 20,
              color: Colors.grey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final authStorage = AuthStorage();
              final token = await authStorage.token;
              if (token == null) {
                CustomWidgets.showSnackBar(
                  "notification".tr,
                  "please_login".tr,
                  Colors.red,
                );
                return;
              }
              if (nameController.text.isNotEmpty) {
                saveFilters(nameController.text);
              }
            },
            label: Text('save'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void resetFilters() {
    // Reset all filter values to their defaults
    selectedVillageId.value = null;
    selectedRegionId.value = null;
    selectedCategoryId.value = null;
    selectedSubCategoryId.value = null;
    selectedInSubCategoryId.value = null;
    totalFloorCount.clear();
    selectedBuildingFloor.clear();
    totalRoomCount.clear();
    selectedRenovation.value = null;
    selectedRenovationId.value = null;
    sellerType.value = null;
    minPriceController.clear();
    maxPriceController.clear();
    minAreaController.clear();
    maxAreaController.clear();
    selectedAreaRange.value = const RangeValues(0, 0);
    update(); // Notify listeners to rebuild UI

    // Reset dependent UI elements
    regions.clear();
    subCategories.clear();
    subinCategories.clear();

    // Optionally, you can refetch the initial data if needed
    // initialize();

    final HomeController homeController = Get.find();
    homeController.shouldFetchAllProperties.value = true;
    print("All filters have been reset.");
  }

  // --- UI DIALOGS & SNACKBARS ---

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'success'.tr,
      message,
      backgroundColor: Colors.green[400],
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(10),
    );
  }

  // void _showErrorSnackbar(String message) {
  //   Get.snackbar(
  //     'error'.tr,
  //     message,
  //     backgroundColor: Colors.blue[200],
  //     colorText: Colors.white,
  //     borderRadius: 12,
  //     margin: const EdgeInsets.all(10),
  //   );
  // }

  void _showNotificationSnackbar(String message) {
    Get.snackbar(
      'notification'.tr,
      message,
      backgroundColor: Colors.blue[200],
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(10),
    );
  }

  void showRenovationPicker() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // const HugeIcon(
                  //   icon: HugeIcons.strokeRoundedPaintRoller,
                  //   size: 24,
                  //   color: Colors.blue,
                  // ),
                  const SizedBox(width: 10),
                  Text('renovation_type'.tr, style: Get.textTheme.titleLarge),
                ],
              ),
            ),
            Obx(() {
              if (remontOptions.isEmpty) {
                return Center(child: Text('renovation_options_not_found'.tr));
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: remontOptions.length,
                itemBuilder: (context, index) {
                  final option = remontOptions[index];
                  return Obx(() => RadioListTile<int>(
                        title: Text(option.name),
                        value: option.id,
                        groupValue: selectedRenovationId.value,
                        onChanged: (value) {
                          if (value != null) {
                            selectRenovation(value, option.name);
                          }
                        },
                      ));
                },
              );
            }),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () => Get.back(),
                label: Text('confirm'.tr),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void showAmenitiesPicker() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckList,
                  size: 24,
                  color: Colors.blue,
                ),
                const SizedBox(width: 10),
                Text('additional_features'.tr, style: Get.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (extrainforms.isEmpty) {
                return Center(child: Text('additional_info_not_found'.tr));
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: extrainforms.length,
                  itemBuilder: (context, index) {
                    final extrainform = extrainforms[index];
                    return Obx(() => SwitchListTile(
                          title: Text(extrainform.name ?? ''),
                          value: extrainform.isSelected.value,
                          onChanged: (bool value) {
                            extrainform.isSelected.value = value;
                          },
                        ));
                  },
                ),
              );
            }),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              label: Text('close_button'.tr),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  void onClose() {
    minPriceController.dispose();
    maxPriceController.dispose();
    minAreaController.removeListener(_onMinAreaChanged);
    maxAreaController.removeListener(_onMaxAreaChanged);
    minAreaController.dispose();
    maxAreaController.dispose();
    super.onClose();
  }
}
