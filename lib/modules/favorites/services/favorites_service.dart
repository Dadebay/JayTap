import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';

class FavoriteService {
  final ApiService _apiService = ApiService();

  Future<bool> addFavorite(int productId) async {
    try {
      final Map<String, String> body = {'product_id': productId.toString()};
      final response = await _apiService.handleApiRequest(
        ApiConstants.createFavorite,
        method: 'POST',
        body: body,
        isForm: true,
        requiresToken: true,
      );

      if (response != null && response['status'] == 'created') {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFavorite(int productId) async {
    try {
      await _apiService.handleApiRequest(
        ApiConstants.removeFavorite + "$productId/",
        method: 'DELETE',
        isForm: false,
        requiresToken: true,
        body: {},
      );
      // Hata fırlatmazsa başarılıdır
      return true;
    } catch (e) {
      return false;
    }
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
      return [];
    }
  }
}
