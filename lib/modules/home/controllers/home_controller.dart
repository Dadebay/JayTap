import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/models/banner_model.dart';
import 'package:jaytap/modules/home/models/category_model.dart';
import 'package:jaytap/modules/home/models/notifcation_model.dart';
import 'package:jaytap/modules/home/models/realtor_model.dart';
import 'package:jaytap/modules/home/service/home_service.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';

class DisplaySubCategory {
  final SubCategoryModel subCategory;
  final int parentCategoryId;

  DisplaySubCategory(
      {required this.subCategory, required this.parentCategoryId});
}

class HomeController extends GetxController {
  var bannerList = <BannerModel>[].obs;
  final RxInt bottomNavBarSelectedIndex = 0.obs;
  var categoryList = <CategoryModel>[].obs;
  var inContentBanners = <BannerModel>[].obs;
  var isLoadingBanners = true.obs;
  var isLoadingCategories = true.obs;
  var isLoadingRealtors = true.obs;
  var realtorList = <RealtorModel>[].obs;
  var topBanners = <BannerModel>[].obs;
  RxList<PropertyModel> propertyList = <PropertyModel>[].obs;
  var isLoadingProperties = true.obs;
  var propertyPage = 1.obs;
  var hasMoreProperties = true.obs;
  var isLoadingMoreProperties = false.obs;
  var filteredPropertyIds = <MapPropertyModel>[].obs;
  var shouldFetchAllProperties = true.obs;

  void setFilteredPropertyIds(List<MapPropertyModel> properties) {
    filteredPropertyIds.assignAll(properties);
  }

  final HomeService _homeService = HomeService();

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  void changePage(int index) {
    bottomNavBarSelectedIndex.value = index;
  }

  Future<void> fetchAllData() async {
    fetchBanners();
    fetchCategories();
    fetchRealtors();
    fetchProperties();
  }

  void refreshPage4Data() async {
    isLoadingProperties(true);
    fetchAllData();
  }

  var isLoadingNotifcations = true.obs;
  var notificationList = <UserNotification>[].obs;

  var notificationPage = 1.obs;
  var hasMoreNotifications = true.obs;
  var isLoadingMoreNotifications = false.obs;
  Future<void> fetchNotifications() async {
    try {
      isLoadingNotifcations(true);
      notificationPage.value = 1;
      hasMoreNotifications.value = true;
      print("__________-Mana geldi");
      var response =
          await _homeService.fetchMyNotifications(page: notificationPage.value);
      print("DEBUG: Full notification response in home_controller: $response");
      if (response != null) {
        print("DEBUG: Notification results: ${response.results}");
        notificationList.assignAll(response.results);
        hasMoreNotifications.value = response.next != null;
      } else {
        hasMoreNotifications.value = false;
        notificationList.clear();
      }
    } finally {
      isLoadingNotifcations(false);
    }
  }

  Future<void> loadMoreNotifications() async {
    if (isLoadingMoreNotifications.value || !hasMoreNotifications.value) return;

    try {
      isLoadingMoreNotifications(true);
      notificationPage.value++;
      var response =
          await _homeService.fetchMyNotifications(page: notificationPage.value);
      if (response != null && response.results.isNotEmpty) {
        notificationList.addAll(response.results);
        hasMoreNotifications.value = response.next != null;
      } else {
        hasMoreNotifications.value = false;
      }
    } finally {
      isLoadingMoreNotifications(false);
    }
  }

  void sendFcmToken() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        print('Firebase Token: $fcmToken');
        await _homeService.sendDeviceId(fcmToken);
      } else {
        print('Firebase Token is null.');
      }
    } catch (e) {
      print('Failed to get FCM token: $e');
    }
  }

  Future<void> fetchProperties() async {
    try {
      isLoadingProperties(true);
      propertyPage.value = 1;
      hasMoreProperties.value = true;
      print('Fetching page: ${propertyPage.value}');
      var response =
          await _homeService.fetchProperties(page: propertyPage.value);
      if (response != null) {
        print('Response received, has next: ${response.next != null}');
        propertyList.assignAll(response.results);
        print('${propertyList.length} properties loaded');
        hasMoreProperties.value = response.next != null;
      } else {
        print('Response is null');
        hasMoreProperties.value = false;
        propertyList.clear();
      }
    } finally {
      isLoadingProperties(false);
    }
  }

  Future<void> loadMoreProperties() async {
    if (isLoadingMoreProperties.value || !hasMoreProperties.value) return;

    try {
      isLoadingMoreProperties(true);
      propertyPage.value++;
      print('Loading more properties, page: ${propertyPage.value}');
      var response =
          await _homeService.fetchProperties(page: propertyPage.value);

      print(response);
      if (response != null && response.results.isNotEmpty) {
        print(
            'More properties response received, has next: ${response.next != null}');
        propertyList.addAll(response.results);
        print('${propertyList.length} total properties');
        hasMoreProperties.value = response.next != null;
      } else {
        print('No more properties or response is null');
        hasMoreProperties.value = false;
      }
    } finally {
      isLoadingMoreProperties(false);
    }
  }

  var displaySubCategories = <DisplaySubCategory>[].obs;

  void fetchCategories() async {
    try {
      isLoadingCategories(true);
      var categories = await _homeService.fetchCategories();
      if (categories.isNotEmpty) {
        categoryList.assignAll(categories);

        var flattenedList = <DisplaySubCategory>[];
        for (var category in categories) {
          for (var sub in category.subcategory) {
            flattenedList.add(DisplaySubCategory(
              subCategory: sub,
              parentCategoryId: category.id,
            ));
          }
        }
        displaySubCategories.assignAll(flattenedList);
      }
    } finally {
      isLoadingCategories(false);
    }
  }

  void fetchRealtors() async {
    try {
      isLoadingRealtors(true);
      var realtors = await _homeService.fetchRealtors();
      if (realtors.isNotEmpty) {
        realtorList.assignAll(realtors);
      }
    } finally {
      isLoadingRealtors(false);
    }
  }

  void fetchBanners() async {
    try {
      isLoadingBanners(true);
      var allBanners = await _homeService.fetchBanners();
      if (allBanners.isNotEmpty) {
        bannerList.assignAll(allBanners);
        topBanners.assignAll(allBanners.where((b) => b.order == 1));
        inContentBanners.assignAll(allBanners.where((b) => b.order == 2));
      }
    } finally {
      isLoadingBanners(false);
    }
  }
}
