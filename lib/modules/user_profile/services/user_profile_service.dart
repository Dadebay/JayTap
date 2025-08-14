import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/core/services/auth_storage.dart';
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

  Future<UserModel?> updateUser({required int userId, required Map<String, String> data}) async {
    final String endpoint = ApiConstants.baseUrl + 'api/users/$userId/';

    final response = await _apiService.handleApiRequest(endpoint, body: data, method: 'PUT', requiresToken: true, isForm: true);

    if (response != null && response is Map<String, dynamic>) {
      try {
        return UserModel.fromJson(response);
      } catch (e) {
        print("updateUser parse error: $e");
        return null;
      }
    }
    return null;
  }

  Future<HelpApiResponse> fetchHelpData() async {
    final response = await _apiService.getRequest(ApiConstants.help, requiresToken: false);
    if (response != null) {
      return HelpApiResponse.fromJson(response);
    } else {
      throw Exception('Yardım verisi alınamadı.');
    }
  }

  Future<UserModel?> updateUserProfile({
    required int userId,
    required String name,
    required String username,
    File? imageFile,
    // Yükleme yüzdesini takip etmek için callback fonksiyonu
    void Function(int, int)? onSendProgress,
  }) async {
    // Sadece bu metot için bir Dio nesnesi oluşturuyoruz
    final dio = Dio();
    final token = AuthStorage().token; // Token'ı alıyoruz

    final String endpoint = '${ApiConstants.baseUrl}api/users/$userId/';

    try {
      // Dio'nun FormData yapısını kullanarak multipart verileri hazırlıyoruz
      final formData = FormData.fromMap({
        'name': name,
        'username': username,
        if (imageFile != null) 'img': await MultipartFile.fromFile(imageFile.path),
      });

      // Dio ile PUT isteğini gönderiyoruz
      final response = await dio.put(
        endpoint,
        data: formData,
        onSendProgress: onSendProgress, // Dio'nun ilerleme takibi özelliğini kullanıyoruz
        options: Options(
          headers: {
            // Token'ı başlığa ekliyoruz
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      // Başarılı olursa, gelen veriyi UserModel'e çevirip döndürüyoruz
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        // Hata durumunda null döndürüyoruz, hata yönetimi DioException bloğunda
        return null;
      }
    } on DioException catch (e) {
      // Ağ veya API hatalarını burada yakalıyoruz
      print("Dio Hatası: ${e.message}");
      // Hata mesajını kullanıcıya gösterebilirsiniz
      // CustomWidgets.showSnackBar("Hata", e.message ?? "Bir sorun oluştu", Colors.red);
      return null;
    } catch (e) {
      // Diğer beklenmedik hatalar
      print("Beklenmedik Hata: $e");
      return null;
    }
  }
}
