import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/auth/views/login_view.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/user_profile/model/user_model.dart';
import 'package:jaytap/modules/user_profile/services/user_profile_service.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

import '../../../core/init/translation_service.dart';

class UserProfilController extends GetxController {
  final List<String> tarifOptions = [
    "type_1",
    "type_2",
    "type_3",
    'type_4',
    'type_5'
  ];
  final RxList<String> selectedTarifs = <String>["type_4"].obs;
  AuthStorage _authStorage = AuthStorage();

  final UserProfileService _userService = UserProfileService();
  var user = Rx<UserModel?>(null);
  var isLoading = true.obs;
  var isProductsLoading = true.obs;
  var myProducts = <PropertyModel>[].obs;
  var isDeleting = false.obs;
  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      final fetchedUser = await _userService.getMe();
      if (fetchedUser != null) {
        user.value = fetchedUser;
        updateSelectedTarifFromApi(fetchedUser.typeTitle);
      } else {
        user.value = null;
      }
    } catch (e) {
      user.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      CustomWidgets.showSnackBar("successTitle", "log_out_message", Colors.red);
      _authStorage.clear();
      await Future.delayed(const Duration(seconds: 2));
      Get.offAll(() => LoginView());
    } catch (e) {
      CustomWidgets.showSnackBar(
          "Hata", "Beklenmedik bir sorun oluştu", Colors.red);
    }
  }

  Future<void> fetchMyProducts() async {
    try {
      isProductsLoading.value = true;
      final products = await _userService.getMyProducts();
      myProducts.assignAll(products);
    } catch (e) {
    } finally {
      isProductsLoading.value = false;
    }
  }

  String getTarifText(String? apiTypeTitle) {
    if (apiTypeTitle == null || apiTypeTitle.isEmpty) {
      return 'user_type_unknown'.tr;
    }

    int? typeNumber = int.tryParse(apiTypeTitle);
    if (typeNumber == null) {
      return 'user_type_unknown'.tr;
    }

    int listIndex = typeNumber - 1;

    if (listIndex >= 0 && listIndex < tarifOptions.length) {
      final translationKey = tarifOptions[listIndex];
      return translationKey.tr;
    }

    return 'user_type_unknown'.tr;
  }

  // YENİ: Güncelleme işleminin durumunu tutmak için
  var isUpdatingProfile = false.obs;
  // YENİ: View'da seçilen resmi tutmak için
  var selectedImageFile = Rx<File?>(null);
  Future<void> updateUserTarif(String newTarif) async {
    if (user.value == null) {
      CustomWidgets.showSnackBar(
          "Hata", "Kullanıcı bilgileri bulunamadı.", Colors.red);
      return;
    }

    // API'ye göndermek için "type_2" -> "2" formatına çevir
    final String typeTitleValue = newTarif.replaceAll('type_', '');
    final int userId = user.value!.id;

    try {
      final updatedUser = await _userService.updateUser(
        userId: userId,
        data: {
          'type_title': typeTitleValue,
          'username': user.value!.username,
        },
      );

      if (updatedUser != null) {
        // Sunucudan gelen yanıtla yerel kullanıcı verisini güncelle
        user.value = updatedUser;
      } else {
        CustomWidgets.showSnackBar(
            "Hata", "Tarif değiştirilemedi.", Colors.red);
      }
    } catch (e) {
      CustomWidgets.showSnackBar(
          "Hata", "Tarif değiştirilirken bir hata oluştu: $e", Colors.red);
    }
  }

  var uploadProgress = 0.0.obs;

  // YENİ METOT: Profil güncelleme mantığı
  Future<void> updateUserProfile(String name) async {
    if (user.value == null) return;

    isUpdatingProfile.value = true;
    uploadProgress.value = 0.0; // Yüklemeye başlarken ilerlemeyi sıfırla

    try {
      final updatedUser = await _userService.updateUserProfile(
        userId: user.value!.id,
        name: name,
        username: user.value!.username,
        imageFile: selectedImageFile.value,
        // İlerleme her değiştiğinde state'i güncelleyen fonksiyon
        onSendProgress: (sent, total) {
          if (total != -1) {
            uploadProgress.value = sent / total;
          }
        },
      );

      if (updatedUser != null) {
        user.value = updatedUser;
        selectedImageFile.value = null;
        Get.back();
        // ...
      }
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // YENİ METOT: Resim seçildiğinde çağrılacak
  void onImageSelected(XFile? pickedFile) {
    if (pickedFile != null) {
      selectedImageFile.value = File(pickedFile.path);
    }
  }

  void updateSelectedTarifFromApi(String typeTitle) {
    int typeIndex = (int.tryParse(typeTitle) ?? 1) - 1;
    if (typeIndex >= 0 && typeIndex < tarifOptions.length) {
      final tarif = tarifOptions[typeIndex];

      if (!selectedTarifs.contains(tarif)) {
        selectedTarifs.clear();
        selectedTarifs.add(tarif);
      }
    }
  }

  void switchLang(String languageCode) {
    Locale newLocale;
    switch (languageCode) {
      case 'tr':
        newLocale = const Locale('tr');
        break;
      case 'en':
        newLocale = const Locale('en');
        break;
      case 'ru':
        newLocale = const Locale('ru');
        break;
      default:
        newLocale = TranslationService.fallbackLocale;
    }
    Get.updateLocale(newLocale);
  }
}
