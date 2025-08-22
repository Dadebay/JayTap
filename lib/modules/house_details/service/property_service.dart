import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart'
    show
        PaginatedPropertyResponse,
        PropertyModel,
        MapPropertyModel,
        PaginatedMapPropertyResponse;
import 'package:jaytap/modules/house_details/models/zalob_model.dart';

class PropertyService {
  final ApiService _apiService = ApiService();
  Future<List<MapPropertyModel>> getPropertiesByCategory(int categoryId) async {
    final endpoint = 'api/getProductCat/$categoryId/';
    final response =
        await _apiService.getRequest(endpoint, requiresToken: false);
    if (response != null && response is Map<String, dynamic>) {
      final paginatedResponse = PaginatedMapPropertyResponse.fromJson(response);
      return paginatedResponse.results;
    } else {
      return [];
    }
  }

  Future<List<ZalobaModel>> getZalobaReasons() async {
    final response = await _apiService.getRequest(ApiConstants.getZalob,
        requiresToken: true);

    if (response != null && response is Map<String, dynamic>) {
      try {
        final paginatedResponse = PaginatedZalobaResponse.fromJson(response);
        return paginatedResponse.results;
      } catch (e) {
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

  Future<bool> toggleFavorite({required int houseId}) async {
    final String endpoint = 'api/favorite_house/'; // Assuming this endpoint
    final Map<String, String> body = {
      'product_id': houseId.toString(),
    };

    final response = await _apiService.handleApiRequest(
      endpoint,
      body: body,
      method: 'POST',
      isForm: true,
      requiresToken: true, // Assuming favorite requires authentication
    );

    return response is Map<String, dynamic> &&
        response['success'] == true; // Assuming API returns {'success': true}
  }

  Future<List<MapPropertyModel>> getAllProperties() async {
    final response = await _apiService.getRequest(ApiConstants.getAllMapItems,
        requiresToken: false);
    print(response);
    if (response != null && response is Map<String, dynamic>) {
      print(response);
      final paginatedResponse = PaginatedMapPropertyResponse.fromJson(response);
      print(paginatedResponse.results);
      return paginatedResponse.results;
    } else {
      return [];
    }
  }

  Future<PaginatedPropertyResponse?> fetchAllProperties() async {
    try {
      final response = await _apiService.getRequest(ApiConstants.getProductList,
          requiresToken: false);

      if (response != null && response is Map<String, dynamic>) {
        return PaginatedPropertyResponse.fromJson(response);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching all properties: $e");
      return null;
    }
  }

  Future<List<MapPropertyModel>> getTajircilikHouses() async {
    final response = await _apiService.getRequest(ApiConstants.getTajircilik,
        requiresToken: false);
    print(response);
    if (response != null && response is Map<String, dynamic>) {
      final paginatedResponse = PaginatedMapPropertyResponse.fromJson(response);
      return paginatedResponse.results;
    } else {
      return [];
    }
  }

  Future<List<MapPropertyModel>> fetchJayByID({required int categoryID}) async {
    final response = await _apiService.getRequest(
        ApiConstants.getJays + '$categoryID/',
        requiresToken: false);
    print(response);
    if (response != null && response is Map<String, dynamic>) {
      final paginatedResponse = PaginatedMapPropertyResponse.fromJson(response);
      return paginatedResponse.results;
    } else {
      return [];
    }
  }

  Future<PropertyModel?> getHouseDetail(int id) async {
    try {
      final url = '${ApiConstants.baseUrl}api/product/$id/';
      print('Requesting house detail for ID: $id, URL: $url'); // Log URL
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        print('Successfully fetched house detail for ID: $id'); // Log success
        return PropertyModel.fromJson(decoded);
      } else {
        print(
            'Failed to fetch house detail for ID: $id. Status Code: ${response.statusCode}, Body: ${response.body}'); // Log error status and body
        return null;
      }
    } catch (e) {
      print(
          'Exception while fetching house detail for ID: $id. Error: $e'); // Log exception
      return null;
    }
  }

  Future<List<Object>> fetchPropertiesByIds({
    required List<int> propertyIds,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (propertyIds.isEmpty) {
      return [];
    }

    String endpointWithParams =
        '${ApiConstants.baseUrl + ApiConstants.getProductList}?page=$page&size=$pageSize';
    print(propertyIds);
    final String idsAsJsonString = jsonEncode(propertyIds);

    print(endpointWithParams);
    print(idsAsJsonString);
    final response = await _apiService.handleApiRequest(
      endpointWithParams,
      body: {
        'list': idsAsJsonString, // <-- DÜZELTİLMİŞ KISIM
      },
      method: 'POST',
      isForm: true,
      requiresToken: false,
    );

    // Bu print'leri hata ayıklama sonrası kaldırabilirsiniz
    print("API'den gelen yanıt: $response");

    if (response != null && response is Map<String, dynamic>) {
      try {
        final paginatedResponse = PaginatedPropertyResponse.fromJson(response);
        return paginatedResponse.results;
      } catch (e) {
        print("fetchPropertiesByIds parse error: $e");
        return [];
      }
    } else {
      print('API Hatası: Beklenmeyen yanıt formatı veya null yanıt.');
      return [];
    }
  }

  Future<List<MapPropertyModel>> searchPropertiesByAddress(
      String address) async {
    final endpoint = 'api/serchbyaddress/?address=$address';
    final response =
        await _apiService.getRequest(endpoint, requiresToken: false);
    if (response != null && response is Map<String, dynamic>) {
      final paginatedResponse = PaginatedMapPropertyResponse.fromJson(response);
      return paginatedResponse.results;
    } else {
      return [];
    }
  }
}
