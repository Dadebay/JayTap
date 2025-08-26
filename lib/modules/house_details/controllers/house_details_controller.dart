import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/models/zalob_model.dart';
import 'package:jaytap/modules/house_details/service/property_service.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

class HouseDetailsController extends GetxController {
  final TextEditingController customZalobaController = TextEditingController();
  final Rx<PropertyModel?> house = Rx<PropertyModel?>(null);
  int? houseId;
  final RxBool isLoadingHouse = true.obs;
  var isLoadingZaloba = true.obs;
  var isSubmittingZaloba = false.obs;
  final int otherOptionId = -1;
  var selectedZalobaId = Rx<int?>(null);
  var zalobaReasons = <ZalobaModel>[].obs;

  final PropertyService _propertyService = PropertyService();

  @override
  void onClose() {
    customZalobaController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    if (houseId != null) {
      fetchHouseDetails(houseId!);
    }
  }

  Future<void> fetchHouseDetails(int id) async {
    houseId = id;
    try {
      isLoadingHouse.value = true;
      final fetchedHouse = await _propertyService.getHouseDetail(id);
      house.value = fetchedHouse;
    } finally {
      isLoadingHouse.value = false;
    }
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

  void selectZaloba(int? id) {
    selectedZalobaId.value = id;
  }

  Future<void> submitZaloba({required int houseId}) async {
    if (selectedZalobaId.value == otherOptionId && customZalobaController.text.trim().isEmpty) {
      CustomWidgets.showSnackBar("error", "writeReasonZalob", Colors.red);

      return;
    }
    try {
      isSubmittingZaloba.value = true;
      bool success;
      if (selectedZalobaId.value == otherOptionId) {
        success = await _propertyService.createZaloba(
          houseId: houseId,
          zalobaId: null,
          customZalob: customZalobaController.text.trim(),
        );
      } else {
        success = await _propertyService.createZaloba(
          houseId: houseId,
          zalobaId: selectedZalobaId.value!,
          customZalob: null,
        );
      }

      if (success) {
        Get.back();
        CustomWidgets.showSnackBar("successTitle", "successSendZalob", Colors.green);
        customZalobaController.clear();
        selectedZalobaId.value = null;
      } else {
        CustomWidgets.showSnackBar("error", "login_error", Colors.red);
      }
    } finally {
      isSubmittingZaloba.value = false;
    }
  }
}
