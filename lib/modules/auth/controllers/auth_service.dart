import 'package:get/get.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/auth/views/connection_check_view.dart';
import 'package:jaytap/modules/auth/views/otp_code_check_view.dart';
import 'package:jaytap/modules/favorites/controllers/favorites_controller.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

class AuthService {
  final AuthStorage _auth = AuthStorage();
  final HomeController _homeController = Get.find<HomeController>();

  Future<void> otpCheck({required String phoneNumber, String? otp}) async {
    final dynamic responseData = await ApiService().handleApiRequest(
        ApiConstants.otpCheckApi,
        body: <String, dynamic>{'phone': phoneNumber, 'otp': otp},
        method: 'POST',
        isForm: true,
        requiresToken: false);
    final token = responseData is Map<String, dynamic>
        ? responseData['access_token']
        : null;
    if (token is String && token.trim().isNotEmpty) {
      await _auth.saveToken(token);
      final favoritesController = Get.find<FavoritesController>();
      favoritesController.checkAndFetchFavorites();
      _homeController.sendFcmToken();
      CustomWidgets.showSnackBar(
          'loginTitle'.tr, 'loginSubtitle'.tr, ColorConstants.greenColor);
      Get.offAll(() => ConnectionCheckView());
      final HomeController homeController = Get.find();

      homeController.changePage(0);
    }
  }

  Future<void> signup({required String phone, required String name}) async {
    final dynamic responseData = await ApiService().handleApiRequest(
      ApiConstants.signUp,
      body: <String, dynamic>{
        'phone': phone,
        'name': name,
      },
      method: 'POST',
      isForm: false,
      requiresToken: false,
    );
    if (responseData == 201 ||
        (responseData is Map && responseData['success'] == true)) {
      Get.to(() => OTPCodeCheckView(phoneNumber: phone));
    } else if (responseData == 409) {
      await login(phone: phone);
    }
  }

  Future<void> login({required String phone}) async {
    final dynamic responseData = await ApiService().handleApiRequest(
      ApiConstants.loginApi,
      body: <String, dynamic>{'phone': phone},
      method: 'POST',
      requiresToken: false,
      isForm: true,
    );
    if (responseData is Map && responseData['success'] == true) {
      Get.to(() => OTPCodeCheckView(phoneNumber: phone));
    }
  }
}
