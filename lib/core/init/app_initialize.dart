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
      await GetStorage.init(); 
      Get.put(ThemeController());
      Get.put(HomeController());
      Get.put(FavoritesController());
      Get.put(UserProfilController());
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      await DeviceUtility.instance.initPackageInfo();
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      final localNotificationsService = LocalNotificationsService.instance();
      await localNotificationsService.init();
      final firebaseMessagingService = FirebaseMessagingService.instance();
      await firebaseMessagingService.init(localNotificationsService: localNotificationsService);
      await FirebaseMessaging.instance.subscribeToTopic('EVENT');
    } catch (e) {}
  }
}
