import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jaytap/core/services/auth_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory storageDirectory;

  setUpAll(() async {
    storageDirectory =
        await Directory.systemTemp.createTemp('jaytap-auth-test-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => storageDirectory.path,
    );
    GetStorage('GetStorage', storageDirectory.path);
    await GetStorage.init();
  });

  tearDownAll(() async {
    await storageDirectory.delete(recursive: true);
  });

  setUp(() async {
    await AuthStorage().clear();
  });

  test('all consumers observe login and offline logout', () async {
    final loginView = AuthStorage();
    final profileView = AuthStorage();

    expect(loginView.isLoggedIn, isFalse);
    expect(profileView.isLoggedInState.value, isFalse);

    await loginView.saveToken('valid-access-token');
    expect(profileView.token, 'valid-access-token');
    expect(profileView.isLoggedInState.value, isTrue);

    await profileView.clear();
    expect(loginView.token, isNull);
    expect(loginView.isLoggedInState.value, isFalse);
  });

  test('missing or malformed access token never starts a session', () async {
    final auth = AuthStorage();
    await expectLater(auth.saveToken(''), throwsArgumentError);
    await expectLater(auth.saveToken('null'), throwsArgumentError);
    expect(auth.isLoggedIn, isFalse);

    await GetStorage().write('AccessToken', 'null');
    expect(auth.token, isNull);
    expect(auth.isLoggedIn, isFalse);
  });
}
