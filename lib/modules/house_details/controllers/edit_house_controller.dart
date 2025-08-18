import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/controllers/add_house_controller.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/service/add_house_service.dart';
import 'package:jaytap/modules/house_details/service/property_service.dart';

class EditHouseController extends AddHouseController {
  final int houseId;
  final PropertyService _propertyService = PropertyService();
  final AddHouseService _addHouseService = AddHouseService();

  EditHouseController({required this.houseId});

  @override
  void onInit() {
    super.onInit();
    // super.onInit();
    isEditMode.value = true;
    _initializeAndFetchDetails();
  }

  Future<void> _initializeAndFetchDetails() async {
    isLoading.value = true;
    await super.initialize();
    await _fetchHouseDetails();
    isLoading.value = false;
  }

  Future<void> _fetchHouseDetails() async {
    final property = await _propertyService.getHouseDetail(houseId);
    if (property != null) {
      descriptionController.text = property.description ?? '';
      areaController.text = property.square?.toString() ?? '';
      priceController.text = property.price?.toString() ?? '';
      phoneController.text = property.phoneNumber ?? '';
      totalFloorCount.value = property.totalfloorcount ?? 1;
      selectedBuildingFloor.value = property.floorcount ?? 1;
      totalRoomCount.value = property.roomcount ?? 1;
      selectVillage(property.villageId ?? 0);
      await fetchRegions(property.villageId ?? 0);
      selectRegion(property.regionId ?? 0);
      selectCategory(property.categoryId ?? 0);
      selectSubCategory(property.subcatId ?? 0);
      selectSubIncategory(property.subincatId ?? 0);

      if (property.specifications != null) {
        for (var spec in property.specifications!) {
          if (specificationCounts.containsKey(spec.id)) {
            specificationCounts[spec.id]!.value = spec.count ?? 0;
          }
        }
      }
      if (property.sphere != null) {
        selectedSpheres.clear();
        for (var sphere in property.sphere!) {
          final existingSphere = spheres.firstWhereOrNull((s) => s.id == sphere.id);
          if (existingSphere != null) {
            selectedSpheres.add(existingSphere);
          }
        }
      }
      if (property.remont != null && property.remont!.isNotEmpty) {
        final remont = remontOptions
            .firstWhereOrNull((r) => r.id == property.remont!.first);
        if (remont != null) {
          selectRenovation(remont.id, remont.name);
        }
      }

      networkImages.clear();
      final dynamic imgUrlAnother = property.imgUrlAnother;
      if (imgUrlAnother != null) {
        if (imgUrlAnother is List && imgUrlAnother.isNotEmpty) {
          networkImages.addAll(imgUrlAnother.map((item) => item.toString()));
        } else if (imgUrlAnother is String && imgUrlAnother.isNotEmpty) {
          networkImages.add(imgUrlAnother);
        }
      }
      final String? mainImg = property.img;
      if (networkImages.isEmpty && mainImg != null && mainImg.isNotEmpty) {
        networkImages.add(mainImg);
      }
    }
  }

  Future<void> submitListing() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    final payload = _buildUpdatePayload();
    final success =
        await _addHouseService.updateProperty(houseId, payload, img: images);
    Get.back();
    if (success) {
      _showSuccessDialog();
    } else {
      _showErrorDialog();
    }
  }

  Map<String, dynamic> _buildUpdatePayload() {
    return {
      "name":
          "${totalRoomCount.value} Room, ${areaController.text} M2, Floor ${selectedBuildingFloor.value}/${totalFloorCount.value}",
      "address":
          "${villages.firstWhere((v) => v.id == selectedVillageId.value, orElse: () => Village(id: 0, nameTm: '')).name ?? ''}, ${regions.firstWhere((r) => r.id == selectedRegionId.value, orElse: () => Village(id: 0, nameTm: '')).name ?? ''}",
      "description": descriptionController.text,
      "village_id": selectedVillageId.value.toString(),
      "totalfloorcount": totalFloorCount.value,
      "floorcount": selectedBuildingFloor.value,
      "roomcount": totalRoomCount.value,
      "price": double.tryParse(priceController.text) ?? 0.0,
      "square": double.tryParse(areaController.text) ?? 0.0,
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
      "img": images,
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
            const Text('Successfully Edit',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'Your listing has been saved and will be published after moderation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.back();
                // Get.offAll(...); // Navigate to home
              },
              child: const Text('OK'),
            )
          ],
        ),
      ),
    );
  }

  void _showErrorDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Error'),
        content: const Text('An error occurred while submitting the listing.'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Close')),
        ],
      ),
    );
  }
}
