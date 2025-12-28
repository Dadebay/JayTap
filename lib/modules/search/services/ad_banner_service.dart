import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/modules/search/models/ad_banner_model.dart';

class AdBannerService {
  final ApiService _apiService = ApiService();

  Future<List<AdBannerModel>> fetchAdBanners() async {
    try {
      final response = await _apiService.getRequest(
        ApiConstants.ads,
        requiresToken: false,
      );

      if (response != null && response is List) {
        return response
            .map((json) => AdBannerModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching ad banners: $e');
      return [];
    }
  }
}
