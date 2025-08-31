import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/favorites/services/favorites_service.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';
import 'package:jaytap/modules/search/models/saved_filter_model.dart';
import 'package:jaytap/modules/search/models/filter_detail_model.dart';
import 'package:jaytap/modules/search/service/filter_service.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

class FavoritesController extends GetxController {
  final FavoriteService _favoriteService = FavoriteService();
  final FilterService _filterService = FilterService();

  final AuthStorage _authStorage = AuthStorage();

  var isLoading = false.obs;
  var favoriteProducts = <PropertyModel>[].obs;
  final RxSet<int> _favoriteProductIds = <int>{}.obs;

  var savedFilters = <SavedFilterModel>[].obs;
  var filterDetails = <FilterDetailModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    print('FavoritesController onInit called');
    checkAndFetchFavorites();
  }

  var isFilterTabActive = false.obs;

  Future<void> fetchFilterDetailsOnTabTap() async {
    if (isFilterTabActive.value && filterDetails.isNotEmpty) {
      return;
    }
    try {
      isLoading.value = true;
      final fetchedDetails = await _filterService.fetchFilterDetails();
      filterDetails.assignAll(fetchedDetails);
    } catch (e) {
      CustomWidgets.showSnackBar(
        'error_title'.tr,
        'login_to_open_filters'.tr,
        Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void checkAndFetchFavorites() {
    print(
        'checkAndFetchFavorites called. isLoggedIn: ${_authStorage.isLoggedIn}');
    if (_authStorage.isLoggedIn) {
      fetchFavorites();
    } else {
      favoriteProducts.clear();
      _favoriteProductIds.clear();
    }
  }

  Future<void> fetchAndDisplayFilterDetails() async {
    try {
      isLoading.value = true;
      final fetchedDetails = await _filterService.fetchFilterDetails();
      filterDetails.assignAll(fetchedDetails);
    } catch (e) {
      CustomWidgets.showSnackBar('Error', 'Failed to load filter details: $e',
          ColorConstants.redColor);
    } finally {
      isLoading.value = false;
    }
  }

  void onSavedFilterTap(int filterId) async {
    try {
      isLoading.value = true;
      final filterData =
          await _filterService.fetchPropertiesByFilterId(filterId);
      final List<int> propertyIds = filterData.map((p) => p.id).toList();
      if (propertyIds.isNotEmpty) {
        final SearchControllerMine searchController =
            Get.find<SearchControllerMine>();
        searchController.loadPropertiesByIds(propertyIds);
        final HomeController homeController = Get.find();
        homeController.changePage(1);
      } else {
        CustomWidgets.showSnackBar(
            'no_properties_found', 'no_properties_found_filter', Colors.red);
      }
    } catch (e) {
      CustomWidgets.showSnackBar('onRetry', 'login_error', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<PropertyModel>> fetchFavorites() async {
    try {
      print('fetchFavorites called');
      isLoading.value = true;
      final products = await _favoriteService.fetchFavoriteProducts();
      favoriteProducts.assignAll(products);

      _favoriteProductIds.clear();
      _favoriteProductIds.addAll(products.map((p) => p.id));
      return products;
    } catch (e) {
      print('Error in fetchFavorites: $e');
      CustomWidgets.showSnackBar('login_error', 'noConnection2', Colors.red);
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(int productId) async {
    final bool isCurrentlyFavorite = isFavorite(productId);
    PropertyModel? productToReAdd;

    if (isCurrentlyFavorite) {
      _favoriteProductIds.remove(productId);
      productToReAdd =
          favoriteProducts.firstWhereOrNull((p) => p.id == productId);
      favoriteProducts.removeWhere((p) => p.id == productId);
    } else {
      _favoriteProductIds.add(productId);
    }

    try {
      bool success;
      if (isCurrentlyFavorite) {
        success = await _favoriteService.removeFavorite(productId);
        if (success) {
          CustomWidgets.showSnackBar(
              'successTitle', 'removed_favorites', Colors.red);
        }
      } else {
        success = await _favoriteService.addFavorite(productId);
        if (success) {
          CustomWidgets.showSnackBar(
              'successTitle', 'added_favorites', Colors.green);
          await fetchFavorites();
        }
      }

      if (!success) {
        throw Exception("API call failed");
      }
    } catch (e) {
      CustomWidgets.showSnackBar('login_error', 'please_login', Colors.red);
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
