import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/modules/home/models/banner_model.dart';
import 'package:jaytap/modules/home/models/category_model.dart';
import 'package:jaytap/modules/home/models/notifcation_model.dart';
import 'package:jaytap/modules/home/models/realtor_model.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart' show PaginatedPropertyResponse;

class HomeService {
  final ApiService _apiService = ApiService();
  Future<List<BannerModel>> fetchBanners() async {
    try {
      final response = await _apiService.getRequest(ApiConstants.banners, requiresToken: false);
      if (response != null && response['results'] is List) {
        final bannerResponse = BannerResponse.fromJson(response);
        return bannerResponse.results;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<void> sendDeviceId(String deviceId) async {
    await _apiService.handleApiRequest(
      ApiConstants.sendDeviceID,
      method: 'POST',
      body: {'device_id': deviceId},
      isForm: true,
      requiresToken: false,
    );
  }

  Future<PaginatedNotificationResponse?> fetchMyNotifications({required int page, int size = 10}) async {
    try {
      final response = await _apiService.getRequest(
        '${ApiConstants.getMyNotifications}?page=$page&size=$size',
        requiresToken: true,
      );
      print('${ApiConstants.getMyNotifications}?page=$page&size=$size');
      if (response != null && response is Map<String, dynamic>) {
        return PaginatedNotificationResponse.fromJson(response);
      } else {
        return null;
      }
    } catch (e) {
      print('Bildirimleri çekerken hata: $e');
      return null;
    }
  }

  Future<List<PropertyModel>> fetchProperties() async {
    final response = await _apiService.getRequest(ApiConstants.products, requiresToken: false);
    if (response != null && response['results'] is List) {
      final propertyResponse = PaginatedPropertyResponse.fromJson(response);
      return propertyResponse.results;
    }
    return [];
  }

  Future<List<CategoryModel>> fetchCategories() async {
    final response = await _apiService.getRequest(ApiConstants.homeCategory, requiresToken: false);
    if (response != null && response is List) {
      List<CategoryModel> categories = response.map((item) => CategoryModel.fromJson(item as Map<String, dynamic>)).toList();
      categories.sort((a, b) => a.id.compareTo(b.id));
      return categories;
    } else {
      return [];
    }
  }

  Future<List<RealtorModel>> fetchRealtors() async {
    try {
      final response = await _apiService.getRequest(ApiConstants.realtors, requiresToken: false);

      if (response != null && response['results'] is List) {
        final realtorResponse = RealtorResponse.fromJson(response);
        return realtorResponse.results.where((user) => user.blok == false).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
