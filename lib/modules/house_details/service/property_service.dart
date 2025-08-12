import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/models/zalob_model.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

class PropertyService {
  final ApiService _apiService = ApiService();
  Future<List<MapPropertyModel>> getPropertiesByCategory(int categoryId) async {
    final endpoint = 'api/getProductCat/$categoryId/';
    final response = await _apiService.getRequest(endpoint, requiresToken: false);
    if (response != null && response is Map<String, dynamic>) {
      final paginatedResponse = PaginatedMapPropertyResponse.fromJson(response);
      print(paginatedResponse);
      print(paginatedResponse.results);
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

  Future<List<MapPropertyModel>> getAllProperties() async {
    final response = await _apiService.getRequest(ApiConstants.getAllMapItems, requiresToken: false);
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

  Future<PaginatedPropertyResponse?> fetchPropertiesByIds({
    required List<int> propertyIds,
    int page = 1,
    int pageSize = 10,
  }) async {
    if (propertyIds.isEmpty) {
      return null;
    }

    String endpointWithParams = '${ApiConstants.getProductList}?page=$page&size=$pageSize';

    final response = await _apiService.handleApiRequest(
      endpointWithParams,
      body: {
        'list': propertyIds.map((id) => id.toString()).toList(),
      },
      method: 'POST',
      isForm: true,
      requiresToken: false,
    );
    print(response);
    print(response);
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
