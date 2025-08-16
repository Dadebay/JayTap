// lib/modules/house_details/service/add_house_service.dart

import 'package:image_picker/image_picker.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';

class AddHouseService {
  final ApiService _apiService = ApiService();

  Future<List<Village>> fetchVillages() async {
    try {
      final response = await _apiService.getRequest(ApiConstants.villages,
          requiresToken: false);
      if (response != null && response['results'] is List) {
        final villageResponse = PaginatedVillageResponse.fromJson(response);
        return villageResponse.results;
      }
      return [];
    } catch (e) {
      print("Köyler (villages) çekilirken hata oluştu: $e");
      return [];
    }
  }

  Future<List<Village>> fetchRegions(int villageId) async {
    try {
      final response = await _apiService.getRequest(
          '${ApiConstants.getRegions}$villageId',
          requiresToken: false);
      if (response != null && response is List) {
        return response.map((e) => Village.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Bölgeler (regions) çekilirken hata oluştu: $e");
      return [];
    }
  }

  Future<List<Category>> fetchCategories() async {
    try {
      final response = await _apiService.getRequest(ApiConstants.categories,
          requiresToken: false);
      if (response != null && response['results'] is List) {
        final categoryResponse = PaginatedCategoryResponse.fromJson(response);
        return categoryResponse.results;
      }
      return [];
    } catch (e) {
      print("Kategoriler çekilirken hata oluştu: $e");
      return [];
    }
  }

  Future<bool> createProperty(
      Map<String, dynamic> payload, List<XFile> images) async {
    try {
      final response = await _apiService.postMultipartRequest(
        ApiConstants.products,
        payload,
        files: images,
      );

      if (response != null) {
        return true;
      }
      return false;
    } catch (e) {
      print("createProperty servisinde hata oluştu: $e");
      return false;
    }
  }

  Future<LimitData?> fetchLimits() async {
    try {
      final response = await _apiService.getRequest(ApiConstants.limits,
          requiresToken: false);
      if (response != null && response['results'] is List) {
        final limitResponse = PaginatedLimitResponse.fromJson(response);
        if (limitResponse.results.isNotEmpty) {
          return limitResponse.results.first;
        }
      }
      return null;
    } catch (e) {
      print("Limitler çekilirken hata oluştu: $e");
      return null;
    }
  }

  Future<List<Specification>> fetchSpecifications() async {
    try {
      final response = await _apiService.getRequest(ApiConstants.specifications,
          requiresToken: false);
      if (response != null && response['results'] is List) {
        return (response['results'] as List)
            .map((e) => Specification.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      print("Spesifikasyonlar çekilirken hata oluştu: $e");
      return [];
    }
  }

  Future<List<RemontOption>> fetchRemontOptions() async {
    try {
      final response = await _apiService.getRequest(ApiConstants.remont,
          requiresToken: false);
      if (response != null && response['results'] is List) {
        return (response['results'] as List)
            .map((e) => RemontOption.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      print("Remont seçenekleri çekilirken hata oluştu: $e");
      return [];
    }
  }

  Future<List<Extrainform>> fetchExtrainforms() async {
    try {
      final response = await _apiService.getRequest(ApiConstants.extrainforms,
          requiresToken: false);
      if (response != null && response['results'] is List) {
        return (response['results'] as List)
            .map((e) => Extrainform.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      print("Ek bilgiler çekilirken hata oluştu: $e");
      return [];
    }
  }
}
