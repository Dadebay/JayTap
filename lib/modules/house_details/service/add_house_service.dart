// lib/modules/house_details/service/add_house_service.dart

import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';

class AddHouseService {
  final ApiService _apiService = ApiService();

  Future<List<Village>> fetchVillages() async {
    try {
      final response = await _apiService.getRequest(ApiConstants.villages, requiresToken: false);
      if (response != null && response['results'] is List) {
        // HATA DÜZELTİLDİ: Doğru paginated response modeli kullanılıyor
        final villageResponse = PaginatedVillageResponse.fromJson(response);
        return villageResponse.results; // Artık doğru tipte (List<Village>) veri dönecek
      }
      return [];
    } catch (e) {
      print("Köyler (villages) çekilirken hata oluştu: $e");
      return [];
    }
  }
}
