// lib/modules/favorites/services/favorite_service.dart

import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/modules/favorites/models/favorites_model.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';

class FavoriteService {
  final ApiService _apiService = ApiService();

  // Favorilere ürün eklemek için
  Future<FavoriteStatus?> addFavorite(int productId) async {
    final response = await _apiService.handleApiRequest(
      ApiConstants.createFavorite,
      method: 'POST',
      body: {'product_id': productId.toString()},
      isForm: true, // Postman'deki gibi multipart/form-data
      requiresToken: true, // Bu işlem token gerektirir
    );
    if (response != null) {
      return FavoriteStatus.fromJson(response);
    }
    return null;
  }

  // Favorilerden ürün çıkarmak için (API endpoint'i genelde farklı olur)
  // Backend'de silme için ayrı bir endpoint yoksa, createFavourite'in
  // toggle (aç/kapa) mantığıyla çalışması gerekir.
  // Varsayılan olarak ayrı bir endpoint olduğunu varsayalım:
  Future<FavoriteStatus?> removeFavorite(int productId) async {
    // NOT: Backend'de silme endpoint'i farklı olabilir. Ör: 'deleteFavourite/'
    // Şimdilik aynı endpoint'i kullandığını varsayıyorum, backend'e göre güncelleyin.
    // Eğer backend aynı endpoint'i hem ekleme hem silme için kullanıyorsa bu doğru.
    // Eğer silme için farklı bir endpoint varsa (örn: /api/deleteFavourite/),
    // ApiConstants'a ekleyip burada onu kullanın.
    final response = await _apiService.handleApiRequest(
      ApiConstants.removeFavorite, // Örnek endpoint, backend'e göre düzenle
      method: 'POST', // veya 'DELETE'
      body: {'product_id': productId.toString()},
      isForm: true,
      requiresToken: true,
    );
    if (response != null) {
      return FavoriteStatus.fromJson(response);
    }
    return null;
  }

  // Kullanıcının favori ürünlerini listelemek için
  Future<List<PropertyModel>> fetchFavoriteProducts() async {
    try {
      final response = await _apiService.getRequest(
        ApiConstants.baseUrl + ApiConstants.getFavorites, // Backend'e göre düzenle
        requiresToken: true,
      );
      if (response != null && response['results'] is List) {
        final paginatedResponse = PaginatedPropertyResponse.fromJson(response);
        return paginatedResponse.results;
      }
      return [];
    } catch (e) {
      print("Favori ürünler çekilirken hata: $e");
      return [];
    }
  }
}
