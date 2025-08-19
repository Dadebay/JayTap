import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/service/add_house_service.dart';

class FilterController extends GetxController {
  final AddHouseService _addHouseService = AddHouseService();

  // --- UI STATE ---
  final isLoading = true.obs;

  // --- FORM DATA ---
  // Location
  final villages = <Village>[].obs;
  final regions = <Village>[].obs;
  final selectedVillageId = 0.obs;
  final selectedRegionId = 0.obs;

  // Categories
  final categories = <Category>[].obs;
  final subCategories = <SubCategory>[].obs;
  final subinCategories = <SubCategory>[].obs;
  final selectedCategoryId = 0.obs;
  final selectedSubCategoryId = 0.obs;
  final selectedInSubCategoryId = 0.obs;

  // Property Details
  final totalFloorCount = 1.obs;
  final selectedBuildingFloor = 1.obs;
  final totalRoomCount = 1.obs;

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
  final sellerType = 'Eýesi'.obs; // Default to Owner

  // Limits
  LimitData? limits;
  final minRoom = 0.obs;
  final maxRoom = 0.obs;
  final minFloor = 0.obs;
  final maxFloor = 0.obs;

  // Price Controllers
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();

  // Area Controllers
  final minAreaController = TextEditingController();
  final maxAreaController = TextEditingController();
  final selectedAreaRange = const RangeValues(100, 500).obs;

  @override
  void onInit() {
    super.onInit();
    initialize();
    // Initialize text controllers and add listeners
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
        selectedAreaRange.value = RangeValues(minVal, selectedAreaRange.value.end);
      }
    } else if (minAreaController.text.isNotEmpty) {
      // Handle invalid input if needed, e.g., reset to the last valid value
    }
  }

  void _onMaxAreaChanged() {
    final maxVal = double.tryParse(maxAreaController.text);
    if (maxVal != null &&
        maxVal >= selectedAreaRange.value.start &&
        maxVal <= 1000) { // Assuming 1000 is the max limit
      if (maxVal != selectedAreaRange.value.end) {
        selectedAreaRange.value = RangeValues(selectedAreaRange.value.start, maxVal);
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
      selectVillage(villages.first.id);
    }
    await fetchCategories();
  }

  Future<void> fetchCategories() async {
    final fetchedCategories = await _addHouseService.fetchCategories();
    if (fetchedCategories.isNotEmpty) {
      categories.value = fetchedCategories;
      selectCategory(categories.first.id);
    }
  }

  Future<void> fetchRegions(int villageId) async {
    regions.clear();
    selectedRegionId.value = 0;
    final fetchedRegions = await _addHouseService.fetchRegions(villageId);
    if (fetchedRegions.isNotEmpty) {
      regions.value = fetchedRegions;
      selectRegion(regions.first.id);
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
    if (subCategories.isNotEmpty) {
      selectSubCategory(subCategories.first.id!);
    } else {
      selectedSubCategoryId.value = 0;
    }
  }

  void selectSubCategory(int subCategoryId) {
    selectedSubCategoryId.value = subCategoryId;
    final selectedSubCategory =
        subCategories.firstWhere((sc) => sc.id == subCategoryId);
    subinCategories.value = selectedSubCategory.subin ?? [];
    if (subinCategories.isNotEmpty) {
      selectSubIncategory(subinCategories.first.id!);
    } else {
      selectedInSubCategoryId.value = 0;
    }
  }

  void selectSubIncategory(int subInCategoryId) {
    selectedInSubCategoryId.value = subInCategoryId;
  }

  void selectBuildingFloor(int floor) {
    if (maxFloor.value > 0 && floor > maxFloor.value) return;
    if (minFloor.value > 0 && floor < minFloor.value) return;
    selectedBuildingFloor.value = floor;
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
  void applyFilters() {
    print("Applying filters...");
    print("Selected Village: ${selectedVillageId.value}");
    print("Selected Region: ${selectedRegionId.value}");
    print("Selected Category: ${selectedCategoryId.value}");
    print("Min Price: ${minPriceController.text}");
    print("Max Price: ${maxPriceController.text}");
    print("Min Area: ${minAreaController.text}");
    print("Max Area: ${maxAreaController.text}");
    print("Seller Type: ${sellerType.value}");
    Get.back();
  }

  void saveFilters() {
    print("Saving filters...");
  }

  void resetFilters() {
    print("Resetting filters...");
  }

  // --- UI DIALOGS ---
  void showRenovationPicker() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Remont görnüşi', style: Get.textTheme.titleLarge),
            ),
            Obx(() {
              if (remontOptions.isEmpty) {
                return const Center(
                    child: Text('Remont seçenekleri bulunamadı'));
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
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('TASSYKLA'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAmenitiesPicker() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Goşmaça', style: Get.textTheme.titleLarge),
            const SizedBox(height: 16),
            Obx(() {
              if (extrainforms.isEmpty) {
                return const Center(child: Text('Ek bilgiler bulunamadı'));
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
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('ÝAP'),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
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