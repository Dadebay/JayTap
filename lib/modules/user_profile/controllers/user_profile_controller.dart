import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/auth/views/login_view.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/user_profile/model/user_model.dart';
import 'package:jaytap/modules/user_profile/services/user_profile_service.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

import '../../../core/init/translation_service.dart';

class UserProfilController extends GetxController {
  final List<String> tarifOptions = ["type_1", "type_2", "type_3", 'type_4'];
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
    if (isDeleting.value) return;

    final userId = user.value?.id;
    if (userId == null) {
      Get.snackbar('Hata', 'Kullanıcı bilgileri bulunamadı, silinemiyor.');
      return;
    }

    try {
      isDeleting.value = true;

      final bool success = await _userService.deleteUserAccount(userId: userId);

      if (success) {
        CustomWidgets.showSnackBar("successTitle", "log_out_message", Colors.red);

        _authStorage.clear();

        await Future.delayed(Duration(seconds: 2));
        Get.offAll(() => LoginView());
      } else {}
    } catch (e) {
      CustomWidgets.showSnackBar("Hata", "Beklenmedik bir sorun oluştu", Colors.red);
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> fetchMyProducts() async {
    try {
      isProductsLoading.value = true;
      final products = await _userService.getMyProducts();
      myProducts.assignAll(products);
    } catch (e) {
      print(e);
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
