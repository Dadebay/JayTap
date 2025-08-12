import 'package:get/get.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/auth/controllers/auth_controller.dart';
import 'package:jaytap/modules/auth/views/otp_code_check_view.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/home/views/bottom_nav_bar_view.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

class AuthService {
  final AuthController authController = Get.put<AuthController>(AuthController());

  final AuthStorage _auth = AuthStorage();
  final HomeController _homeController = Get.find<HomeController>();

  Future<void> otpCheck({required String phoneNumber, String? otp}) async {
    final dynamic responseData =
        await ApiService().handleApiRequest(ApiConstants.otpCheckApi, body: <String, dynamic>{'phone': phoneNumber, 'otp': otp}, method: 'POST', isForm: true, requiresToken: false);
    if (responseData is Map<String, dynamic>) {
      _auth.saveToken(responseData['access_token'].toString());
      _homeController.sendFcmToken();
      CustomWidgets.showSnackBar('loginTitle'.tr, 'loginSubtitle'.tr, ColorConstants.greenColor);
      Get.offAll(() => BottomNavBar());
    }
  }

  Future<void> signup({required String phone, required String name}) async {
    final int? statusCode = await ApiService().handleApiRequest(
      ApiConstants.signUp, // Bu sabiti ApiConstants dosyanıza eklemeyi unutmayın
      body: <String, dynamic>{
        'phone': phone,
        'name': name,
      },
      method: 'POST',
      isForm: true, // Multipart/form-data gönderimi için
      requiresToken: false,
    );
    print(statusCode);
    print(statusCode);
    print(statusCode);
    if (statusCode == 201) {
      Get.to(() => OTPCodeCheckView(phoneNumber: phone));
    } else if (statusCode == 409) {
      await AuthService().login(phone: phone);
    }
  }

  Future<void> login({required String phone}) async {
    print("Login gitdim Men-----------------------------------------");
    final dynamic responseData = await ApiService().handleApiRequest(
      ApiConstants.loginApi,
      body: <String, dynamic>{'phone': phone},
      method: 'POST',
      requiresToken: false,
      isForm: true,
    );
    print(responseData);
    if (responseData['success'] == true) {
      Get.to(() => OTPCodeCheckView(phoneNumber: phone));
    }
  }
}
