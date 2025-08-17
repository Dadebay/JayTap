import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/favorites/services/favorites_service.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

class SavedFilter {
  final String name;
  SavedFilter(this.name);
}

class FavoritesController extends GetxController {
  final FavoriteService _favoriteService = FavoriteService();

  final AuthStorage _authStorage = AuthStorage();

  var isLoading = false.obs;
  var favoriteProducts = <PropertyModel>[].obs;
  final RxSet<int> _favoriteProductIds = <int>{}.obs;

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
      favoriteProducts.clear();
      _favoriteProductIds.clear();
    }
  }

  Future<List<PropertyModel>> fetchFavorites() async {
    try {
      isLoading.value = true;
      final products = await _favoriteService.fetchFavoriteProducts();
      favoriteProducts.assignAll(products);

      _favoriteProductIds.clear();
      _favoriteProductIds.addAll(products.map((p) => p.id));
      return products;
    } catch (e) {
      CustomWidgets.showSnackBar('Hata', 'Favoriler yüklenirken bir sorun oluştu.', Colors.red);
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(int productId) async {
    final bool isCurrentlyFavorite = isFavorite(productId);
    PropertyModel? productToReAdd;

    // UI'ı anında güncelle (Optimistic Update)
    if (isCurrentlyFavorite) {
      _favoriteProductIds.remove(productId);
      productToReAdd = favoriteProducts.firstWhereOrNull((p) => p.id == productId);
      favoriteProducts.removeWhere((p) => p.id == productId);
    } else {
      _favoriteProductIds.add(productId);
    }

    try {
      bool success;
      if (isCurrentlyFavorite) {
        success = await _favoriteService.removeFavorite(productId);
        if (success) {
          CustomWidgets.showSnackBar('Success', 'Haryt halanlarymdan aýryldy', Colors.red);
        }
      } else {
        success = await _favoriteService.addFavorite(productId);
        if (success) {
          CustomWidgets.showSnackBar('Success', 'Haryt halanlaryma goşuldy', Colors.green);
          await fetchFavorites();
        }
      }

      if (!success) {
        throw Exception("API call failed");
      }
    } catch (e) {
      CustomWidgets.showSnackBar('Hata', 'Ulgama Girmegini hayys edyaris.', Colors.red);
      // Hata durumunda UI'ı eski haline getir
      if (isCurrentlyFavorite) {
        _favoriteProductIds.add(productId);
        if (productToReAdd != null) {
          favoriteProducts.add(productToReAdd);
        }
      } else {
        _favoriteProductIds.remove(productId);
      }
    }
  }

  bool isFavorite(int productId) => _favoriteProductIds.contains(productId);
  int get filtersCount => savedFilters.length;
}
