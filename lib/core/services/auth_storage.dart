import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthStorage extends GetxService {
  AuthStorage._() : isLoggedInState = false.obs {
    isLoggedInState.value = isLoggedIn;
  }

  static final AuthStorage _instance = AuthStorage._();
  factory AuthStorage() => _instance;

  final GetStorage _storage = GetStorage();
  final RxBool isLoggedInState;

  String? get token {
    final stored = _storage.read<String>('AccessToken');
    return stored == null || stored.trim().isEmpty || stored == 'null'
        ? null
        : stored;
  }

  String? get refreshToken => _storage.read<String>('RefreshToken');

  Future<void> saveToken(String token) async {
    if (token.trim().isEmpty || token == 'null') {
      throw ArgumentError.value(token, 'token', 'A valid token is required');
    }
    await _storage.write('AccessToken', token);
    isLoggedInState.value = true;
  }

  Future<void> saveRefreshToken(String token) =>
      _storage.write('RefreshToken', token);

  Future<void> clear() async {
    await _storage.remove('AccessToken');
    await _storage.remove('RefreshToken');
    isLoggedInState.value = false;
  }

  bool get isLoggedIn => token != null;
}
