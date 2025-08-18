// lib/modules/home/services/banner_service.dart

import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/modules/home/models/banner_model.dart';
import 'package:jaytap/modules/home/models/category_model.dart';
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
      isForm: true, // Use multipart/form-data
      requiresToken: false, // Assuming no auth token is needed for this
    );
  }

  Future<List<PropertyModel>> fetchProperties() async {
    try {
      final response = await _apiService.getRequest(ApiConstants.products, requiresToken: false);
      if (response != null && response['results'] is List) {
        final propertyResponse = PaginatedPropertyResponse.fromJson(response);
        return propertyResponse.results;
      }
      return [];
    } catch (e, stackTrace) {
      print("Error fetching or parsing properties: $e");
      print(stackTrace);
      return [];
    }
  }

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await _apiService.getRequest(ApiConstants.categories, requiresToken: false);
      if (response != null && response['results'] is List) {
        final categoryResponse = CategoryResponse.fromJson(response);
        categoryResponse.results.sort((a, b) => a.id.compareTo(b.id));
        return categoryResponse.results;
      } else {
        return [];
      }
    } catch (e) {
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
