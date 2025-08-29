import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart'; // Import HomeController
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/models/zalob_model.dart';
import 'package:jaytap/modules/house_details/service/add_house_service.dart';
import 'package:jaytap/modules/house_details/service/property_service.dart';
import 'package:jaytap/modules/house_details/views/add_house_view/full_screen_map_view.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/init/translation_service.dart';

class AddHouseController extends GetxController {
  final AddHouseService _addHouseService = AddHouseService();
  final PropertyService _propertyService = PropertyService();
  final mapController = MapController();
  // --- UI STATE ---
  final isEditMode = false.obs;
  final isLoading = true.obs;
  final isVip = false.obs;

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
  final descriptionController = TextEditingController();
  final areaController = TextEditingController();
  final priceController = TextEditingController();
  final phoneController = TextEditingController();
  final totalFloorCount = 1.obs;
  final selectedBuildingFloor = 1.obs;
  final totalRoomCount = 1.obs;
  // State'ler
  var zalobaReasons = <ZalobaModel>[].obs;
  var isLoadingZaloba = true.obs;
  var selectedZalobaId = Rx<int?>(null); // Seçilen şikayet nedeni
  var isSubmittingZaloba = false.obs;
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

  List<Extrainform> get selectedAmenities =>
      extrainforms.where((e) => e.isSelected.value).toList();

  // Images
  final images = <XFile>[].obs;
  final networkImages = <String>[].obs;
  final _picker = ImagePicker();

  // Map

  final selectedLocation = Rx<LatLng?>(null);
  final mapCenter = const LatLng(37.95, 58.38).obs;
  final userLocation = Rx<LatLng?>(null);

  // Limits
  LimitData? limits;
  final minRoom = 0.obs;
  final maxRoom = 0.obs;
  final minFloor = 0.obs;
  final maxFloor = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    isLoading.value = true;
    await Future.wait([
      fetchInitialData(),
      _determinePosition(),
      _fetchLimits(),
      _fetchSpecifications(),
      _fetchRemontOptions(),
      _fetchExtrainforms(),
      _fetchSpheres(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchZalobaReasons() async {
    try {
      isLoadingZaloba.value = true;
      final reasons = await _propertyService.getZalobaReasons();
      zalobaReasons.assignAll(reasons);
    } finally {
      isLoadingZaloba.value = false;
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

  // --- COUNTER HANDLERS ---
  void changeSpecificationCount(int specificationId, int change) {
    final currentCount = specificationCounts[specificationId]!.value;
    if (currentCount + change >= 0) {
      specificationCounts[specificationId]!.value += change;
    }
  }

  void changeRoomCount(RxInt counter, int change) {
    if (counter == totalRoomCount) {
      if (maxRoom.value > 0 && counter.value + change > maxRoom.value) return;
      if (minRoom.value > 0 && counter.value + change < minRoom.value) return;
    }
    if (counter.value + change >= 0) counter.value += change;
  }

  // --- IMAGE HANDLING ---
  Future<void> pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      images.addAll(pickedFiles);
    }
  }

  void removeImage(int index) {
    images.removeAt(index);
  }

  void removeNetworkImage(String url) {
    networkImages.remove(url);
  }

  // --- MAP HANDLING ---
  Future<void> _determinePosition() async {
    try {
      final position = await _getDevicePosition();
      final latLng = LatLng(position.latitude, position.longitude);
      userLocation.value = latLng;
      selectedLocation.value = latLng;
      mapCenter.value = latLng;
    } catch (e) {
      print(e);
      _showErrorSnackbar(e.toString());
    }
  }

  Future<Position> _getDevicePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void openFullScreenMap() {
    Get.to(() => FullScreenMapView(
          initialLocation: mapCenter.value,
          onLocationSelected: (latlng) {
            selectedLocation.value = latlng;
            mapCenter.value = latlng;
            mapController.move(latlng, mapController.camera.zoom);
            Get.back();
          },
          userCurrentLocation: userLocation.value,
        ));
  }

  // --- UI DIALOGS ---

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
                  Text('renovation_picker_title'.tr,
                      style: Get.textTheme.titleLarge),
                ],
              ),
            ),
            Obx(() {
              if (remontOptions.isEmpty) {
                return Center(child: Text('no_renovation_options_found'.tr));
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
                label: Text('close_button'.tr),
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
                Text('amenities_picker_title'.tr,
                    style: Get.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (extrainforms.isEmpty) {
                return Center(child: Text('no_amenities_found'.tr));
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

  final isSubmitting = false.obs;

  // --- SUBMISSION ---
  void submitListing() {
    if (isSubmitting.value) return; // Prevent multiple submissions

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Text('confirm_submission_title'.tr),
          ],
        ),
        content: Text('confirm_submission_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel_button'.tr),
          ),
          Obx(() => ElevatedButton.icon(
                onPressed: isSubmitting.value
                    ? null
                    : () async {
                        Get.back();
                        isSubmitting.value = true;
                        await _processSubmission();
                        isSubmitting.value = false;
                      },
                label: isSubmitting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ))
                    : Text('confirm_button'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _processSubmission() async {
    try {
      final payload = _buildPayload();
      final productId = await _addHouseService.createProperty(payload);
      print('Product ID after createProperty: $productId');

      if (productId != null) {
        if (images.isNotEmpty) {
          final bool uploadSuccess =
              await _addHouseService.uploadPhotos(productId, images);
          print('Image upload success: $uploadSuccess');
          if (!uploadSuccess) {
            print('Image upload failed.');
            _showErrorSnackbar('Image upload failed.');
            return;
          }
        }
        print('Calling _showSuccessDialog()...');
        _showSuccessDialog();
      } else {
        _showErrorSnackbar('Failed to create property.');
        print("GECMEDI");
      }
    } catch (e) {
      _showErrorSnackbar('An error occurred: $e');
      print("Error during submission: $e");
    } finally {
      // isSubmitting.value = false; // This is now handled in the onPressed of the confirm button
    }
  }

  Map<String, dynamic> _buildPayload() {
    return {
      "name":
          "${totalRoomCount.value}-${('room_word'.tr)} • ${areaController.text} м² • ${selectedBuildingFloor.value}/${totalFloorCount.value} ${('floor_word'.tr)}",
      "address":
          "${villages.firstWhere((v) => v.id == selectedVillageId.value, orElse: () => Village(id: 0, nameTm: '')).name ?? ''}, ${regions.firstWhere((r) => r.id == selectedRegionId.value, orElse: () => Village(id: 0, nameTm: '')).name ?? ''}",
      "description": descriptionController.text,
      "village_id": selectedVillageId.value.toString(),
      "totalfloorcount": totalFloorCount.value,
      "floorcount": selectedBuildingFloor.value,
      "roomcount": totalRoomCount.value,
      "price": double.tryParse(priceController.text) ?? 0.0,
      "square": double.tryParse(areaController.text) ?? 0.0,
      "created": DateTime.now().toIso8601String(),
      "lat": selectedLocation.value?.latitude.toString(),
      "long": selectedLocation.value?.longitude.toString(),
      "category_id": selectedCategoryId.value,
      "subcat_id": selectedSubCategoryId.value,
      "subincat_id": selectedInSubCategoryId.value,
      "region_id": selectedRegionId.value.toString(),
      "phone_number": phoneController.text,
      "sphere": selectedSpheres.map((s) => s.id).toList(),
      "remont": selectedRenovationId.value != null
          ? [selectedRenovationId.value!]
          : [],
      "specification": specificationCounts.entries
          .where((entry) => entry.value.value > 0)
          .map((entry) => {"id": entry.key, "count": entry.value.value})
          .toList(),
      "extrainform": extrainforms
          .where((e) => e.isSelected.value)
          .map((e) => e.id)
          .toList(),
      "vip": false,
    };
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green,
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text('submission_success_title'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('submission_success_message'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final HomeController homeController = Get.find();
                homeController.refreshPage4Data();
                Get.back();
                Get.back();
                homeController.changePage(0);
              },
              child: Text('ok_button'.tr),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[400],
      colorText: Colors.white,
      borderRadius: 12,
      margin: const EdgeInsets.all(10),
    );
  }

  @override
  void onClose() {
    descriptionController.dispose();
    areaController.dispose();
    priceController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
