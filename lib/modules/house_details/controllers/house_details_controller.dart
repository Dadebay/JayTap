// lib/modules/house_details/controllers/house_details_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/models/zalob_model.dart';
import 'package:jaytap/modules/house_details/service/property_service.dart';

class HouseDetailsController extends GetxController {
  final PropertyService _propertyService = PropertyService();

  // State'ler
  var zalobaReasons = <ZalobaModel>[].obs;
  var isLoadingZaloba = true.obs;
  var selectedZalobaId = Rx<int?>(null); // Seçilen şikayet nedeni
  var isSubmittingZaloba = false.obs;

  // "Diğer" seçeneği için özel ID
  final int otherOptionId = -1;
  final TextEditingController customZalobaController = TextEditingController();

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

  // ** BU METOT TAMAMEN YENİLENDİ **
  Future<void> submitZaloba({required int houseId}) async {
    // Hiçbir şey seçilmediyse
    if (selectedZalobaId.value == null) {
      Get.snackbar('Hata', 'Lütfen bir şikayet nedeni seçin.');
      return;
    }

    // "Diğer" seçildi ama metin boşsa
    if (selectedZalobaId.value == otherOptionId &&
        customZalobaController.text.trim().isEmpty) {
      Get.snackbar('Hata', 'Lütfen şikayet nedeninizi yazın.');
      return;
    }

    try {
      isSubmittingZaloba.value = true;

      bool success;

      // Kullanıcı "Diğer" seçeneğini mi seçti?
      if (selectedZalobaId.value == otherOptionId) {
        // Evet, o zaman SADECE metni gönder, zalobaId null olsun.
        success = await _propertyService.createZaloba(
          houseId: houseId,
          zalobaId: null, // ID gönderme
          customZalob: customZalobaController.text.trim(),
        );
      } else {
        // Hayır, hazır bir neden seçti. SADECE ID'yi gönder.
        success = await _propertyService.createZaloba(
          houseId: houseId,
          zalobaId: selectedZalobaId.value!,
          customZalob: null, // Metin gönderme
        );
      }

      if (success) {
        Get.back(); // Diyaloğu kapat
        Get.snackbar('Başarılı', 'Şikayetiniz başarıyla gönderildi.');
        customZalobaController.clear();
        selectedZalobaId.value = null;
      } else {
        Get.snackbar('Hata', 'Şikayet gönderilirken bir sorun oluştu.');
      }
    } finally {
      isSubmittingZaloba.value = false;
    }
  }

  @override
  void onClose() {
    customZalobaController.dispose();
    super.onClose();
  }
}
