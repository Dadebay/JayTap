import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/auth/views/connection_check_view.dart';
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
      Get.offAll(() => ConnectionCheckView());
    } catch (e) {}
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

    // 3 ve 4 için özel durum:
    if (typeNumber == 3 || typeNumber == 4) {
      return 'filter_owner'.tr; // 👈 senin özel metnin
    }

    int listIndex = typeNumber - 1;

    if (listIndex >= 0 && listIndex < tarifOptions.length) {
      final translationKey = tarifOptions[listIndex];
      return translationKey.tr;
    }

    return 'user_type_unknown'.tr;
  }

  var isUpdatingProfile = false.obs;

  var selectedImageFile = Rx<File?>(null);
  Future<void> updateUserTarif(String newTarif) async {
    if (user.value == null) {
      return;
    }

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
        user.value = updatedUser;
      }
    } catch (e) {}
  }

  var uploadProgress = 0.0.obs;

  Future<void> updateUserProfile(String name) async {
    if (user.value == null) return;

    isUpdatingProfile.value = true;
    uploadProgress.value = 0.0;

    try {
      final updatedUser = await _userService.updateUserProfile(
        userId: user.value!.id,
        name: name,
        username: user.value!.username,
        imageFile: selectedImageFile.value,
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
      }
    } finally {
      isUpdatingProfile.value = false;
    }
  }

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
    final storage = GetStorage();
    storage.write('langCode', languageCode);
  }
}
