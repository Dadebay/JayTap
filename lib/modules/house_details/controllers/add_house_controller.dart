import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart'; // Import HomeController
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/models/zalob_model.dart';
import 'package:jaytap/modules/house_details/service/add_house_service.dart';
import 'package:jaytap/modules/house_details/service/property_service.dart';
import 'package:jaytap/modules/house_details/views/add_house_view/full_screen_map_view.dart';
import 'package:latlong2/latlong.dart';

class AddHouseController extends GetxController {
  final AddHouseService _addHouseService = AddHouseService();
  final PropertyService _propertyService = PropertyService();
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

  // Images
  final images = <XFile>[].obs;
  final networkImages = <String>[].obs;
  final _picker = ImagePicker();

  // Map

  final selectedLocation = Rx<LatLng?>(null);
  final markers = <Marker>[].obs;
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
    final selectedSubCategory = subCategories.firstWhere((sc) => sc.id == subCategoryId);
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
      print('User Location: ${userLocation.value}');
      print('Selected Location: ${selectedLocation.value}');
      _updateMarkers(latLng);
    } catch (e) {
      print(e);
      // CustomWidgets.showSnackBar('Error', e.toString(), Colors.red);
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
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _updateMarkers(LatLng location) {
    markers.clear();
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: location,
        child: const Icon(
          IconlyBold.location,
          color: Colors.red,
          size: 40.0,
        ),
      ),
    );
  }

  void openFullScreenMap() {
    Get.to(() => FullScreenMapView(
          initialLocation: userLocation.value,
          onLocationSelected: (latlng) {
            selectedLocation.value = latlng;

            _updateMarkers(latlng);
            Get.back();
          },
          userCurrentLocation: userLocation.value,
        ));
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
                return const Center(child: Text('Remont seçenekleri bulunamadı'));
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
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
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
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // --- SUBMISSION ---
  void submitListing() {
    Get.dialog(
      AlertDialog(
        title: const Text('Bildirişi tassykla'),
        content: const Text('Bu bildirişi tassyklamak isleýärsiňizmi?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Ýatyr')),
          FilledButton(
            onPressed: () {
              Get.back();
              _processSubmission();
            },
            child: const Text('Tassykla'),
          ),
        ],
      ),
    );
  }

  Future<void> _processSubmission() async {
    final payload = _buildPayload();
    final productId = await _addHouseService.createProperty(payload);
    print('Product ID after createProperty: $productId'); // Debug print

    if (productId != null) {
      if (images.isNotEmpty) {
        final bool uploadSuccess = await _addHouseService.uploadPhotos(productId, images);
        print('Image upload success: $uploadSuccess'); // Debug print
        if (!uploadSuccess) {
          print('Image upload failed.'); // Debug print
          return;
        }
      }
      print('Calling _showSuccessDialog()...'); // Debug print
      _showSuccessDialog();
    } else {
      print("GECMEDI");
    }
  }

  Map<String, dynamic> _buildPayload() {
    return {
      "name": "${totalRoomCount.value} Otag, ${areaController.text} M², Etaz ${selectedBuildingFloor.value}/${totalFloorCount.value}",
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
      "remont": selectedRenovationId.value != null ? [selectedRenovationId.value!] : [],
      "specification": specificationCounts.entries.where((entry) => entry.value.value > 0).map((entry) => {"id": entry.key, "count": entry.value.value}).toList(),
      "extrainform": extrainforms.where((e) => e.isSelected.value).map((e) => e.id).toList(),
      "vip": false,
    };
  }

  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text('Successfully Submitted', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Your listing has been saved and will be published after moderation.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final HomeController homeController = Get.find();
                homeController.refreshPage4Data();
                Get.back();
                Get.back();
                homeController.changePage(0);
              },
              child: const Text('OK'),
            )
          ],
        ),
      ),
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
