import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthStorage extends GetxService {
  final GetStorage _storage = GetStorage();

  late final RxBool isLoggedInState;

  AuthStorage() {
    isLoggedInState = (token != null).obs;
  }

  String? get token => _storage.read<String>('AccessToken');
  String? get refreshToken => _storage.read<String>('RefreshToken');

  void saveToken(String token) {
    _storage.write('AccessToken', token);
    isLoggedInState.value = true;
  }

  void saveRefreshToken(String token) => _storage.write('RefreshToken', token);

  void clear() {
    _storage.remove('AccessToken');
    _storage.remove('RefreshToken');
    isLoggedInState.value = false;
  }

  bool get isLoggedIn => token != null;
}
