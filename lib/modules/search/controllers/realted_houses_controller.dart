// ============================================
// CONTROLLER - realted_houses_controller.dart
// ============================================
import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/service/property_service.dart';
import 'package:jaytap/modules/search/controllers/filter_controller.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RealtedHousesController extends GetxController {
  final PropertyService _propertyService = PropertyService();

  var isLoading = false.obs;
  var properties = <PropertyModel>[].obs;
  var currentPage = 1.obs;
  var hasNextPage = true.obs;
  var isGridView = true.obs;
  var isFiltered = false.obs;
  var currentFilter = RxnString();
  var nextPageUrl = RxnString();

  var isMoreLoading = false.obs;

  List<int> _currentPropertyIds = [];
  List<int> get currentPropertyIds => _currentPropertyIds;

  // ✅ IndexedStack için state kaydı
  var isInitialized = false.obs;

  final RefreshController refreshController = RefreshController();

  int _fetchGeneration = 0; // ✅ Request ID counter

  void resetFilterState() {
    isFiltered.value = false;
    currentFilter.value = null;
    nextPageUrl.value = null;
    currentPage.value = 1;
    hasNextPage.value = true;
    _fetchGeneration++; // Invalidate pending requests
  }

  void checkGlobalFilterState() {
    bool hasMapFilter = false;
    bool hasDetailedFilter = false;

    if (Get.isRegistered<SearchControllerMine>()) {
      hasMapFilter = Get.find<SearchControllerMine>().hasActiveMapFilter;
    }

    if (Get.isRegistered<FilterController>()) {
      hasDetailedFilter = Get.find<FilterController>().hasActiveFilters;
    }

    // ✅ Eğer herhangi bir filter aktifse isFiltered true olsun
    if (hasMapFilter || hasDetailedFilter) {
      isFiltered.value = true;
      // Map veya Detailed filter varsa 'custom_filter' olarak işaretle
      if (currentFilter.value == null ||
          currentFilter.value != 'frommin' &&
              currentFilter.value != 'frommax' &&
              currentFilter.value != 'new' &&
              currentFilter.value != 'old') {
        currentFilter.value = 'custom_filter';
      }
    } else {
      isFiltered.value = false;
      currentFilter.value = null;
    }

    print(
        '🔍 Global Filter Check: Map=$hasMapFilter, Detailed=$hasDetailedFilter => isFiltered=${isFiltered.value}');
  }

  Future<void> fetchPropertiesByIds({
    required bool isRefresh,
    required List<int> propertyIds,
  }) async {
    // ✅ Start new generation
    final int myGeneration = ++_fetchGeneration;

    // ✅ Eğer zaten yükleme yapılıyorsa tekrar çağırma (Refresh hariç)
    // NOTE: generation check handles concurrency better, but this guard is still good for UI state
    if ((isLoading.value || isMoreLoading.value) && !isRefresh) {
      print('⚠️ Already loading, skipping request...');
      return;
    }

    // ✅ Her zaman güncel ID listesini kullan
    _currentPropertyIds = propertyIds;

    // ✅ Refresh ise önce loading'i başlat ki UI "Boş" hatası vermesin
    if (isRefresh) {
      isLoading.value = true;
    }

    // ✅ Refresh ise tüm state'i sıfırla
    if (isRefresh) {
      currentPage.value = 1;
      hasNextPage.value = true;
      properties.clear();
      refreshController.resetNoData(); // Reset footer state
    }

    // ✅ Pagination bitmiş ise yükleme
    if (!hasNextPage.value && !isRefresh) {
      print('🚫 Pagination finished, no more data.');
      refreshController.loadNoData();
      isLoading.value = false; // Ensure loading is off if we return early
      return;
    }

    try {
      if (!isRefresh) {
        isMoreLoading.value = true;
      }

      print('📡 Fetching page: ${currentPage.value} (Gen: $myGeneration)');

      final response = await _propertyService.fetchPropertiesByIds(
        propertyIds: _currentPropertyIds,
        page: currentPage.value,
        pageSize: 10,
      );

      // ✅ CRITICAL: Check if this request is stale
      if (_fetchGeneration != myGeneration) {
        print('🚫 Request aborted (stale generation: local=$myGeneration, current=$_fetchGeneration)');
        // Ensure UI loading state is reset if we are "stuck" here? 
        // No, the NEW request is responsible for managing isLoading.
        // But if we returned early, we might leave isLoading=true?
        // Wait, the NEW request sets isLoading=true.
        // So we can just return.
        return;
      }

      print('✅ Loaded ${response.length} properties');

      // ✅ Refresh değilse ekle, refresh ise zaten temizlendi
      if (!isRefresh) {
        properties.addAll(response.cast<PropertyModel>());
      } else {
        properties.assignAll(response.cast<PropertyModel>());
      }
      
      // ... (Pagination Logic)
      if (response.length < 10) {
        hasNextPage.value = false;
        print('🚫 No more pages (received ${response.length} items)');
      } else {
        hasNextPage.value = true;
        currentPage.value++;
        print('📄 Next page: ${currentPage.value}');
      }

      // ✅ İlk yükleme tamamlandı
      if (!isInitialized.value) {
        isInitialized.value = true;
      }

      // ✅ RefreshController state güncelleme
      if (isRefresh) {
        refreshController.refreshCompleted();
        // Eğer ilk sayfada data azsa ve loadMore gerekmiyorsa footer'ı güncelle
        if (!hasNextPage.value) {
          refreshController.loadNoData();
        }
      } else {
        if (hasNextPage.value) {
          refreshController.loadComplete();
        } else {
          refreshController.loadNoData();
        }
      }
    } catch (e) {
      print('❌ Error fetching properties: $e');
      Get.snackbar('Hata', 'İlanlar yüklenirken bir sorun oluştu.');

      if (isRefresh) {
        refreshController.refreshFailed();
      } else {
        refreshController.loadFailed();
      }
    } finally {
      // ✅ Only reset if this is the current generation
      if (_fetchGeneration == myGeneration) {
        isLoading.value = false;
        isMoreLoading.value = false;
      }
    }
  }

  Future<List<int>> applyFilter(String filterType,
      {bool isRefresh = false}) async {
    // ✅ Start new generation
    final int myGeneration = ++_fetchGeneration;

    // ✅ Clear list to show loader immediately (User Request: "Lottie'ye gitmeli")
    isLoading.value = true;
    if (isRefresh) {
      properties.clear();
      refreshController.resetNoData();
    }

    // ✅ Custom Filter (Map veya Detailed) varsa Client-Side Sort yap
    if (isFiltered.value &&
        (currentFilter.value == 'custom_filter' ||
            currentFilter.value == 'filter_view' ||
            _currentPropertyIds.isNotEmpty)) {
      print(
          '🔄 Applying Client-Side Sort: $filterType on ${_currentPropertyIds.length} items (Gen: $myGeneration)');
      
      // Note: _sortFilteredProperties will handle its own generation check if called directly,
      // but since we call it here, we should pass the generation or let it handle its own.
      // Actually, _sortFilteredProperties is a helper. Let's make sure it doesn't conflict.
      // Easiest is to let _sortFilteredProperties manage its own generation if called publicly,
      // OR just rely on this one.
      // To be safe and simple: ISOLATE _sortFilteredProperties logic or just call it.
      // Since _sortFilteredProperties is async and could be called independently? 
      // It is private (_) but called above.
      
      // Let's delegate to _sortFilteredProperties but we need to pass context or handle it there.
      // For now, let's just properly implement _sortFilteredProperties and call it.
      return await _sortFilteredProperties(filterType, isRefresh: isRefresh);
    }

    String apiUrl = 'https://jaytap.com.tm/api/filtermaxmin/?';
    switch (filterType) {
      case 'frommin':
        apiUrl += 'frommin=True';
        break;
      case 'frommax':
        apiUrl += 'frommax=True';
        break;
      case 'new':
        apiUrl += 'new=True';
        break;
      case 'old':
        apiUrl += 'old=True';
        break;
      default:
        // Reset loading if we abort
        if (_fetchGeneration == myGeneration) isLoading.value = false;
        return [];
    }

    try {
      // already set: isLoading.value = true;
      final response = await http.get(Uri.parse(apiUrl));

      // ✅ Check Generation
      if (_fetchGeneration != myGeneration) return [];

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> data = responseBody['results'] ?? [];

        nextPageUrl.value = responseBody['next'];

        List<PropertyModel> filteredProperties =
            data.map((e) => PropertyModel.fromJson(e)).toList();

        isFiltered.value = true;
        currentFilter.value = filterType;

        setProperties(filteredProperties);
        
        // ✅ Sync internal ID list so View doesn't re-fetch
        _currentPropertyIds = filteredProperties.map((e) => e.id).toList();

        if (isRefresh) {
          refreshController.refreshCompleted();
          // Eğer ilk sayfada data azsa ve loadMore gerekmiyorsa footer'ı güncelle
          if (nextPageUrl.value == null) {
            refreshController.loadNoData();
          } else {
            refreshController.resetNoData();
          }
        }

        // Return IDs for sync
        return filteredProperties.map((e) => e.id).toList();
      } else {
        print('Error: ${response.statusCode}');
        Get.snackbar(
            "Error", "Failed to load filtered data: ${response.statusCode}");
        if (isRefresh) {
          refreshController.refreshFailed();
        }
        return [];
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
      print("An error occurred: $e");
      if (isRefresh) {
        refreshController.refreshFailed();
      }
      return [];
    } finally {
      // ✅ Only reset if this is the current generation
      if (_fetchGeneration == myGeneration) {
        isLoading.value = false;
      }
    }
  }

  Future<List<int>> _sortFilteredProperties(String filterType,
      {bool isRefresh = false}) async {
    // ✅ Start new generation
    final int myGeneration = ++_fetchGeneration;

    // ✅ Clear list to show loader immediately
    isLoading.value = true;
    if (isRefresh) {
      properties.clear();
      refreshController.resetNoData();
    }

    try {
      // already set: isLoading.value = true;

      // 1. Fetch ALL properties for current IDs (using large page size)
      // Note: We use _currentPropertyIds which holds the filtered IDs
      final allProperties = await _propertyService.fetchPropertiesByIds(
        propertyIds: _currentPropertyIds,
        page: 1,
        pageSize: 1000, // Fetch enough to sort all
      );

      // ✅ Check Generation
      if (_fetchGeneration != myGeneration) return [];

      List<PropertyModel> propertyList = allProperties.cast<PropertyModel>();

      // 2. Sort in Dart
      switch (filterType) {
        case 'frommin':
          propertyList.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
          break;
        case 'frommax':
          propertyList.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
          break;
        case 'new':
          propertyList.sort((a, b) =>
              b.id.compareTo(a.id)); // Assuming ID correlates with date
          break;
        case 'old':
          propertyList.sort((a, b) => a.id.compareTo(b.id));
          break;
      }

      // 3. Update State
      properties.assignAll(propertyList);
      hasNextPage.value = false; // Since we fetched all
      currentPage.value = 1;
      currentFilter.value =
          filterType; // Update filter type so UI shows selected

      if (isRefresh) {
        refreshController.refreshCompleted();
        refreshController.loadNoData();
      }

      return propertyList.map((e) => e.id).toList();
    } catch (e) {
      print('❌ Error sorting filtered properties: $e');
      Get.snackbar('Hata', 'Sıralama yapılırken bir sorun oluştu.');
      if (isRefresh) refreshController.refreshFailed();
      return [];
    } finally {
      // ✅ Only reset if this is the current generation
      if (_fetchGeneration == myGeneration) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMoreFilteredData() async {
    if (nextPageUrl.value == null) {
      refreshController.loadNoData();
      return;
    }

    if (isMoreLoading.value) {
      print('⚠️ Already loading more filtered data, skipping request...');
      return;
    }

    try {
      isMoreLoading.value = true;
      final response = await http.get(Uri.parse(nextPageUrl.value!));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> data = responseBody['results'] ?? [];

        nextPageUrl.value = responseBody['next'];

        List<PropertyModel> newProperties =
            data.map((e) => PropertyModel.fromJson(e)).toList();

        properties.addAll(newProperties);

        if (nextPageUrl.value == null) {
          refreshController.loadNoData();
        } else {
          refreshController.loadComplete();
        }
      } else {
        refreshController.loadFailed();
      }
    } catch (e) {
      print("Load more error: $e");
      refreshController.loadFailed();
    } finally {
      isMoreLoading.value = false;
    }
  }

  void toggleView() {
    isGridView.value = !isGridView.value;
  }

  void setProperties(List<PropertyModel> newProperties) {
    properties.assignAll(newProperties);
    hasNextPage.value = false;
    currentPage.value = 1;
  }

  // ✅ IndexedStack'te widget görünür hale geldiğinde çağrılır
  void onBecameVisible() {
    print('🔄 Widget became visible');
    // Eğer daha önce yüklenmediyse, yükle
    if (!isInitialized.value) {
      print('📥 Loading initial data...');
    }
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
