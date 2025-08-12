import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/user_profile/model/about_us_model.dart';
import 'package:jaytap/modules/user_profile/model/help_model.dart';
import 'package:jaytap/modules/user_profile/model/user_model.dart';

class UserProfileService {
  final ApiService _apiService = ApiService();

  Future<AboutApiResponse> fetchAboutData() async {
    final response = await _apiService.getRequest(ApiConstants.about, requiresToken: false);
    if (response != null) {
      return AboutApiResponse.fromJson(response);
    } else {
      throw Exception('Hakkında verisi alınamadı.');
    }
  }

  Future<UserModel?> getMe() async {
    final response = await _apiService.getRequest(ApiConstants.getMe, requiresToken: true);
    print(response);
    if (response != null && response is Map<String, dynamic>) {
      try {
        return UserModel.fromJson(response);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<bool> deleteUserAccount({required int userId}) async {
    final String endpoint = '${ApiConstants.realtors}$userId/';

    final response = await _apiService.handleApiRequest(
      endpoint,
      body: {},
      method: 'DELETE',
      requiresToken: true,
    );
    print(response);
    print(response);
    print(response);
    print(response);
    print(response);
    if (response is Map<String, dynamic>) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<PropertyModel>> getMyProducts() async {
    final response = await _apiService.getRequest(ApiConstants.getMyProducts, requiresToken: true);

    if (response != null && response is List) {
      try {
        return response.map((json) => PropertyModel.fromJson(json)).toList();
      } catch (e) {
        print("getMyProducts parse error: $e");
        return [];
      }
    }

    return [];
  }

  Future<HelpApiResponse> fetchHelpData() async {
    final response = await _apiService.getRequest(ApiConstants.help, requiresToken: false);
    if (response != null) {
      return HelpApiResponse.fromJson(response);
    } else {
      throw Exception('Yardım verisi alınamadı.');
    }
  }
}
