// lib/modules/favorites/controllers/favorites_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/favorites/services/favorites_service.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/shared/widgets/widgets.dart'; // CustomWidgets.showSnackBar için

class SavedFilter {
  final String name;
  SavedFilter(this.name);
}

class FavoritesController extends GetxController {
  final FavoriteService _favoriteService = FavoriteService();
  // AuthStorage'ı Get.find ile bulalım. Bunun için önce onu bir yere put etmelisiniz.
  // Örneğin main.dart içinde: Get.put(AuthStorage());
  final AuthStorage _authStorage = AuthStorage();

  // --- State Değişkenleri ---
  var isLoading = false.obs;
  var favoriteProducts = <PropertyModel>[].obs;
  final RxSet<int> _favoriteProductIds = <int>{}.obs;

  // --- State Değişkenleri ---

  var savedFilters = <SavedFilter>[
    SavedFilter("Ashgabat - Elitka jaylar"),
    SavedFilter("Mary - Sowda merkezleri"),
  ].obs;

  @override
  void onInit() {
    super.onInit();

    checkAndFetchFavorites();
  }

  void checkAndFetchFavorites() {
    if (_authStorage.isLoggedIn) {
      fetchFavorites();
    } else {
      // Giriş yapılmamışsa listeleri temizle
      favoriteProducts.clear();
      _favoriteProductIds.clear();
    }
  }
  // --- API Fonksiyonları ---

  Future<void> fetchFavorites() async {
    try {
      isLoading.value = true;
      final products = await _favoriteService.fetchFavoriteProducts();
      favoriteProducts.assignAll(products);
      // Favori ID'lerini hızlı kontrol için bir Set'e alalım
      _favoriteProductIds.clear();
      _favoriteProductIds.addAll(products.map((p) => p.id));
    } catch (e) {
      CustomWidgets.showSnackBar('Hata', 'Favoriler yüklenirken bir sorun oluştu.', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(int productId) async {
    // 1. Token kontrolü
    if (!_authStorage.isLoggedIn) {
      CustomWidgets.showSnackBar('Giriş Gerekli', 'Favorilere eklemek için lütfen giriş yapın.', Colors.orange);
      return;
    }

    // Mevcut durum
    final bool isCurrentlyFavorite = isFavorite(productId);

    // 2. UI'ı anında güncelle (Optimistic UI)
    if (isCurrentlyFavorite) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }

    // 3. API'ye isteği gönder
    try {
      if (isCurrentlyFavorite) {
        // Favorilerden çıkar
        await _favoriteService.removeFavorite(productId);
      } else {
        // Favorilere ekle
        await _favoriteService.addFavorite(productId);
      }
      // Başarılı olursa favori listesini yenileyebiliriz.
      fetchFavorites();
    } catch (e) {
      // 4. Hata durumunda UI'ı geri al
      CustomWidgets.showSnackBar('Hata', 'İşlem sırasında bir sorun oluştu.', Colors.red);
      if (isCurrentlyFavorite) {
        _favoriteProductIds.add(productId);
      } else {
        _favoriteProductIds.remove(productId);
      }
    }
  }

  // --- Yardımcı Fonksiyonlar ---
  bool isFavorite(int productId) => _favoriteProductIds.contains(productId);
  int get filtersCount => savedFilters.length;
}
