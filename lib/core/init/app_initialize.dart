import 'dart:async';

// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jaytap/core/init/firebase_messaging_service.dart';
import 'package:jaytap/core/init/local_notifications_service.dart';
import 'package:jaytap/core/init/theme_controller.dart';
import 'package:jaytap/firebase_options.dart';
import 'package:jaytap/modules/favorites/controllers/favorites_controller.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';
import 'package:kartal/kartal.dart';
import 'package:logger/logger.dart';

@immutable
final class ApplicationInitialize {
  const ApplicationInitialize._();

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await runZonedGuarded<Future<void>>(_initialize, (error, stack) {
      // Logger().e(error.toString());
    });
  }

  static Future<void> _initialize() async {
    try {
      // Hataları yakalamak için try-catch ekleyelim
      print('[INIT] Adım 1: Controllerlar yükleniyor...');
      Get.put(ThemeController());
      Get.put(FavoritesController());
      Get.put(HomeController());
      Get.put(UserProfilController());
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      print('[INIT] Adım 2: DeviceUtility başlatılıyor...');
      await DeviceUtility.instance.initPackageInfo();
      print('[INIT] Adım 3: GetStorage başlatılıyor...');
      await GetStorage.init();
      print('[INIT] Adım 4: Firebase başlatılıyor...');
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      print('[INIT] Adım 5: LocalNotificationsService başlatılıyor...');
      final localNotificationsService = LocalNotificationsService.instance();
      await localNotificationsService.init();
      print('[INIT] Adım 6: FirebaseMessagingService başlatılıyor...');
      final firebaseMessagingService = FirebaseMessagingService.instance();
      await firebaseMessagingService.init(localNotificationsService: localNotificationsService);
      print('[INIT] Adım 7: Topice abone olunuyor...');
      await FirebaseMessaging.instance.subscribeToTopic('EVENT');
      print('[INIT] ----- BAŞLATMA TAMAMLANDI! -----');
    } catch (e, stack) {
      print('!!!!!! BAŞLATMA SIRASINDA KRİTİK HATA !!!!!!');
      print('Hata: $e');
      print('Stack Trace: $stack');
    }
  }
}
