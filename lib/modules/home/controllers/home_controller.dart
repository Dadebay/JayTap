// lib/modules/home/controllers/home_controller.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/models/banner_model.dart';
import 'package:jaytap/modules/home/models/category_model.dart';
import 'package:jaytap/modules/home/models/notifcation_model.dart';
import 'package:jaytap/modules/home/models/realtor_model.dart';
import 'package:jaytap/modules/home/service/home_service.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart'; // Corrected the path based on your code

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
  var propertyList = <PropertyModel>[].obs;
  var isLoadingProperties = true.obs;
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
      print(response);
      if (response != null) {
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
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      print('Firebase Token: $fcmToken');
      await _homeService.sendDeviceId(fcmToken);
    } else {
      print('Firebase Token is null.');
    }
  }

  void fetchProperties() async {
    try {
      isLoadingProperties(true);
      var properties = await _homeService.fetchProperties();
      if (properties.isNotEmpty) {
        propertyList.assignAll(properties);
      }
    } finally {
      isLoadingProperties(false);
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
