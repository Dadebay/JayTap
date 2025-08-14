import 'package:flutter/material.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/modules/favorites/models/favorites_model.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

class FavoriteService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>?> addFavorite(int productId) async {
    final Map<String, String> body = {'product_id': productId.toString()};

    final response = await _apiService.handleApiRequest(
      ApiConstants.createFavorite,
      method: 'POST',
      body: body,
      isForm: true,
      requiresToken: true,
    );
    print("Added_-----------------------");
    print(response);
    if (response['status'] == 'created') {
      CustomWidgets.showSnackBar('Success', 'Haryt halanlaryma gosuldy ', Colors.green);
    }
    return response;
  }

  Future<Map<String, dynamic>?> removeFavorite(int productId) async {
    final Map<String, String> body = {'product_id': productId.toString()};

    final response = await _apiService.handleApiRequest(
      ApiConstants.createFavorite,
      method: 'POST',
      body: body,
      isForm: true,
      requiresToken: true,
    );
    print(response);

    return response;
  }

  Future<List<PropertyModel>> fetchFavoriteProducts() async {
    try {
      final response = await _apiService.getRequest(
        ApiConstants.getFavorites,
        requiresToken: true,
      );

      if (response != null && response is List) {
        // Gelen her bir JSON objesini işle
        return response
            .map((json) {
              // EĞER ÜRÜN BİLGİSİ 'product' ANAHTARI İÇİNDEYSE:
              if (json['product'] != null && json['product'] is Map) {
                return PropertyModel.fromJson(json['product']);
              }
              // EĞER DOĞRUDAN KÖK DİZİNDEYSE:
              return PropertyModel.fromJson(json);
            })
            .toList()
            .cast<PropertyModel>();
      }
      return [];
    } catch (e) {
      print("Favori ürünler çekilirken hata: $e");
      return [];
    }
  }
}
