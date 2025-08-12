// lib/modules/home/controllers/home_controller.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/models/banner_model.dart';
import 'package:jaytap/modules/home/models/category_model.dart';
import 'package:jaytap/modules/home/models/realtor_model.dart';
import 'package:jaytap/modules/home/service/home_service.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart'; // Corrected the path based on your code

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
  var propertyList = <PropertyModel>[].obs; // YENİ EKLENDİ
  var isLoadingProperties = true.obs; // YENİ EKLENDİ

  final HomeService _homeService = HomeService();

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  void changePage(int index) {
    bottomNavBarSelectedIndex.value = index;
  }

  void fetchAllData() {
    fetchBanners();
    fetchCategories();
    fetchRealtors();
    fetchProperties();
  }

  void sendFcmToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await _homeService.sendDeviceId(fcmToken);
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

  void fetchCategories() async {
    try {
      isLoadingCategories(true);
      var categories = await _homeService.fetchCategories();
      if (categories.isNotEmpty) {
        categoryList.assignAll(categories);
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
