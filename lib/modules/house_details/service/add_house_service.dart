// lib/modules/house_details/service/add_house_service.dart
import 'dart:convert';
import 'dart:developer';
import 'package:image_picker/image_picker.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/models/zalob_model.dart';

class AddHouseService {
  final ApiService _apiService = ApiService();
  Future<List<ZalobaModel>> getZalobaReasons() async {
    final response = await _apiService.getRequest(ApiConstants.getZalob,
        requiresToken: true);

    if (response != null && response is Map<String, dynamic>) {
      try {
        final paginatedResponse = PaginatedZalobaResponse.fromJson(response);
        return paginatedResponse.results;
      } catch (e) {
        print("getZalobaReasons parse error: $e");
        return [];
      }
    }
    return [];
  }

  Future<bool> createZaloba({
    required int houseId,
    int? zalobaId,
    String? customZalob,
  }) async {
    final String endpoint = 'functions/zaloba/';

    final Map<String, String> body = {
      'product_id': houseId.toString(),
      if (zalobaId != null) 'zaloba_id': zalobaId.toString(),
      if (customZalob != null && customZalob.isNotEmpty) 'zalob': customZalob,
    };

    if (zalobaId == null && (customZalob == null || customZalob.isEmpty)) {
      print("Hata: Gönderilecek bir şikayet nedeni bulunamadı.");
      return false;
    }

    final response = await _apiService.handleApiRequest(
      endpoint,
      body: body,
      method: 'POST',
      isForm: true,
      requiresToken: true,
    );

    return response is Map<String, dynamic>;
  }

  /// Generic method to fetch paginated data from the API.
  Future<List<T>> _fetchPaginatedData<T>(
    String endpoint,
    T Function(Map<String, dynamic>) fromJson, {
    String? errorMessage,
  }) async {
    try {
      final response =
          await _apiService.getRequest(endpoint, requiresToken: false);
      if (response != null && response['results'] is List) {
        final paginatedResponse =
            PaginatedResponse.fromJson(response, fromJson);
        return paginatedResponse.results;
      }
      return [];
    } catch (e, stackTrace) {
      log(errorMessage ?? 'Error fetching data from $endpoint',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Fetches a list of villages.
  Future<List<Village>> fetchVillages() async {
    return _fetchPaginatedData(
      ApiConstants.villages,
      (json) => Village.fromJson(json),
      errorMessage: 'Error fetching villages',
    );
  }

  /// Fetches a list of regions for a given village ID.
  Future<List<Village>> fetchRegions(int villageId) async {
    try {
      final response = await _apiService.getRequest(
          '${ApiConstants.getRegions}$villageId',
          requiresToken: false);
      if (response != null && response is List) {
        return response.map((e) => Village.fromJson(e)).toList();
      }
      return [];
    } catch (e, stackTrace) {
      log('Error fetching regions', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  /// Fetches a list of categories.
  Future<List<Category>> fetchCategories() async {
    return _fetchPaginatedData(
      ApiConstants.categories,
      (json) => Category.fromJson(json),
      errorMessage: 'Error fetching categories',
    );
  }

  /// Creates a new property listing.
  Future<int?> createProperty(Map<String, dynamic> payload) async {
    try {
      print('Request Body (JSON): ${jsonEncode(payload)}');

      final response = await _apiService.handleApiRequest(
        ApiConstants.products,
        body: payload,
        method: 'POST',
        requiresToken: true,
      );

      if (response is int) {
        print('API Call: ${ApiConstants.products} - Status Code: $response');
        return null;
      } else if (response is Map<String, dynamic>) {
        print('API Call: ${ApiConstants.products} - Response Body: $response');
        if (response['id'] != null) {
          return response['id'] as int;
        }
      }
      return null;
    } catch (e, stackTrace) {
      log('Error in createProperty service', error: e, stackTrace: stackTrace);
      print('Error details: $e');
      return null;
    }
  }

  Future<List<String>?> uploadPhotos(int productId, List<XFile> images) async {
    List<String> uploadedImageUrls = [];
    try {
      final requestBody = {
        'product_id': productId,
      };
      print('Upload Photo Request Body: $requestBody');
      final response = await _apiService.postMultipartRequest(
        ApiConstants.uploadPhotos,
        requestBody,
        xFiles: images,
      );

      if (response is int) {
        print(
            'API Call: ${ApiConstants.uploadPhotos} - Status Code: $response');
      } else if (response is Map<String, dynamic>) {
        print(
            'API Call: ${ApiConstants.uploadPhotos} - Response Body: $response');
        if (response['data'] is List) {
          uploadedImageUrls
              .addAll((response['data'] as List).map((e) => e.toString()));
        } else if (response['data'] is String) {
          uploadedImageUrls.add(response['data']);
        }
      } else {
        log('API Call: ${ApiConstants.uploadPhotos} - Failed to upload photos, Response: $response');
      }
      return uploadedImageUrls;
    } catch (e, stackTrace) {
      log('Error uploading photos', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Updates an existing property listing.
  Future<bool> updateProperty(int id, Map<String, dynamic> payload,
      {List<XFile>? img}) async {
    try {
      final List<XFile>? images = payload.remove('img') as List<XFile>?;
      log('Updating property $id with images: ${images?.length}');
      final response = await _apiService.putMultipartRequest(
        '${ApiConstants.products}$id/',
        payload,
        files: images,
      );
      return response;
    } catch (e, stackTrace) {
      log('Error in updateProperty service', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Fetches the limits for property attributes.
  Future<LimitData?> fetchLimits() async {
    final results = await _fetchPaginatedData(
      ApiConstants.limits,
      (json) => LimitData.fromJson(json),
      errorMessage: 'Error fetching limits',
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Fetches a list of specifications.
  Future<List<Specification>> fetchSpecifications() async {
    return _fetchPaginatedData(
      ApiConstants.specifications,
      (json) => Specification.fromJson(json),
      errorMessage: 'Error fetching specifications',
    );
  }

  /// Fetches a list of renovation options.
  Future<List<RemontOption>> fetchRemontOptions() async {
    return _fetchPaginatedData(
      ApiConstants.remont,
      (json) => RemontOption.fromJson(json),
      errorMessage: 'Error fetching remont options',
    );
  }

  /// Fetches a list of extra information options.
  Future<List<Extrainform>> fetchExtrainforms() async {
    return _fetchPaginatedData(
      ApiConstants.extrainforms,
      (json) => Extrainform.fromJson(json),
      errorMessage: 'Error fetching extra informs',
    );
  }

  /// Fetches a list of spheres.
  Future<List<Sphere>> fetchSpheres() async {
    return _fetchPaginatedData(
      ApiConstants.sphere,
      (json) => Sphere.fromJson(json),
      errorMessage: 'Error fetching spheres',
    );
  }
}

/// A generic class for paginated API responses.
class PaginatedResponse<T> {
  final List<T> results;

  PaginatedResponse({required this.results});

  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return PaginatedResponse(
      results: (json['results'] as List<dynamic>)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
