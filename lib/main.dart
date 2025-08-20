import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jaytap/core/init/app_initialize.dart';
import 'package:jaytap/core/init/theme_controller.dart';
import 'package:jaytap/core/init/translation_service.dart';
import 'package:jaytap/core/theme/custom_dark_theme.dart';
import 'package:jaytap/core/theme/custom_light_theme.dart';
import 'package:jaytap/routes/app_pages.dart';
import 'package:jaytap/routes/app_routes.dart';

Future<void> main() async {
  await ApplicationInitialize.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return GetMaterialApp(
          translations: TranslationService(),
          defaultTransition: Transition.fade,
          fallbackLocale: const Locale('tr'),
          debugShowCheckedModeBanner: false,
          locale: storage.read('langCode') != null
              ? Locale(storage.read('langCode'))
              : const Locale('tr'),
          theme: CustomLightTheme().themeData,
          darkTheme: CustomDarkTheme().themeData,
          themeMode: Get.find<ThemeController>().themeMode,
          getPages: AppPages.pages,
          initialRoute: Routes.CONNECTIONCHECKVIEW,
        );
      },
    );
  }
}
