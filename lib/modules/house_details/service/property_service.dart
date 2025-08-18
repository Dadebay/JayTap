import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    final response = await _apiService.getRequest(ApiConstants.getZalob, requiresToken: true);

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

    return response is Map<String, dynamic> && response['success'] == true; // Assuming API returns {'success': true}
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

  Future<List<MapPropertyModel>> getTajircilikHouses() async {
    final response = await _apiService.getRequest(ApiConstants.getTajircilik, requiresToken: false);
    print(response);
    if (response != null && response is Map<String, dynamic>) {
      final paginatedResponse = PaginatedMapPropertyResponse.fromJson(response);
      return paginatedResponse.results;
    } else {
      return [];
    }
  }

  Future<List<MapPropertyModel>> fetchJayByID({required int categoryID}) async {
    final response = await _apiService.getRequest(ApiConstants.getJays + '$categoryID/', requiresToken: false);
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
      final response = await http.get(Uri.parse('${ApiConstants.baseUrl}api/product/$id/'));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        return PropertyModel.fromJson(decoded);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

    Future<PaginatedPropertyResponse?> fetchPropertiesByIds({
    required List<int> propertyIds,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (propertyIds.isEmpty) {
      return PaginatedPropertyResponse(
          results: [], next: null, previous: null, count: 0);
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
        return PaginatedPropertyResponse.fromJson(response);
      } catch (e) {
        print("fetchPropertiesByIds parse error: $e");
        return null;
      }
    } else {
      print('API Hatası: Beklenmeyen yanıt formatı veya null yanıt.');
      return null;
    }
  }
}
