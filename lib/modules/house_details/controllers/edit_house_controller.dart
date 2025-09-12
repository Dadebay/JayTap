import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/house_details/controllers/add_house_controller.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/service/add_house_service.dart';
import 'package:jaytap/modules/house_details/service/property_service.dart';

class EditHouseController extends AddHouseController {
  final PropertyService _propertyService = PropertyService();
  final AddHouseService _addHouseService = AddHouseService();
  int? currentHouseId;

  EditHouseController();

  Future<void> loadHouseForEditing(int houseId) async {
    currentHouseId = houseId;
    isLoading.value = true;
    isEditMode.value = true;
    await super.fetchInitialData();
    await _fetchHouseDetails(houseId);
    isLoading.value = false;
  }

  Future<void> _fetchHouseDetails(int houseId) async {
    final property = await _propertyService.getHouseDetail(houseId);
    if (property != null) {
      descriptionController.text = property.description ?? '';
      areaController.text = property.square?.toString() ?? '';
      priceController.text = property.price?.toString() ?? '';
      phoneController.text = property.phoneNumber ?? '';
      totalFloorCount.value = property.totalfloorcount ?? 1;
      selectedBuildingFloor.value = property.floorcount ?? 1;
      totalRoomCount.value = property.roomcount ?? 1;

      if (property.village != null) {
        selectVillage(property.village!.id);
        await fetchRegions(property.village!.id);
        if (property.region != null) {
          selectRegion(property.region!.id);
        }
      }
      if (property.category != null) {
        selectCategory(property.category!.id);
      }

      if (property.specifications != null) {
        for (var spec in property.specifications!) {
          if (specificationCounts.containsKey(spec.spec.id)) {
            specificationCounts[spec.spec.id]!.value = spec.count;
          }
        }
      }

      if (property.sphere != null) {
        selectedSpheres.clear();
        for (var sphere in property.sphere!) {
          final existingSphere =
              spheres.firstWhereOrNull((s) => s.id == sphere.id);
          if (existingSphere != null) {
            selectedSpheres.add(existingSphere);
          }
        }
      }

      // Pre-select renovation type
      if (property.remont != null && property.remont!.isNotEmpty) {
        final remontId = property.remont!.first.id;
        final remont = remontOptions.firstWhereOrNull((r) => r.id == remontId);
        if (remont != null) {
          selectRenovation(remont.id, remont.name);
        }
      }

      // Pre-select extra information
      if (property.extrainform != null) {
        for (var extra in property.extrainform!) {
          final existingExtra =
              extrainforms.firstWhereOrNull((e) => e.id == extra.id);
          if (existingExtra != null) {
            existingExtra.isSelected.value = true;
          }
        }
      }

      // Populate network images
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
      isVip.value = property.vip ?? false;
    }
  }

  Future<void> submitListing() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final bool textUpdateSuccess = await _addHouseService.updateProperty(
        currentHouseId!, _buildUpdatePayload());

    if (!textUpdateSuccess) {
      Get.back();
      _showErrorDialog();
      return;
    }

    if (images.isNotEmpty) {
      final bool uploadedImageUrls =
          await _addHouseService.uploadPhotos(currentHouseId!, images);
      Get.back();

      if (uploadedImageUrls) {
        _showSuccessDialog();
      } else {
        // _showErrorDialog(
        //     message: 'Ev bilgileri güncellendi, ancak fotoğraf yüklenemedi.');
      }
    } else {
      Get.back();
      _showSuccessDialog();
    }
  }

  Map<String, dynamic> _buildUpdatePayload() {
    return {
      "name":
          "${totalRoomCount.value}-${('room_word'.tr)} • ${areaController.text} м² • ${selectedBuildingFloor.value}/${totalFloorCount.value}  ${('floor_word'.tr)}",
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
      "vip": isVip.value,
      "img": images,
    };
  }

  final HomeController homeController = Get.put(HomeController());
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
              onPressed: () async {
                Get.close(3);
                final HomeController homeController = Get.find();
                homeController.changePage(4);
                homeController.refreshPage4Data();
              },
              child: const Text('OK'),
            )
          ],
        ),
      ),
    );
  }

  void _showErrorDialog({String? message}) {
    Get.dialog(
      AlertDialog(
        title: const Text('Error'),
        content:
            Text(message ?? 'An error occurred while submitting the listing.'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Close')),
        ],
      ),
    );
  }
}
