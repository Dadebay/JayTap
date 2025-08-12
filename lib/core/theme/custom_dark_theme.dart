import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';

final class CustomDarkTheme {
  final ThemeData themeData = ThemeData(
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: ColorConstants.blackColor, statusBarIconBrightness: Brightness.light),
    ),
    fontFamily: 'Roboto',
    colorScheme: CustomColorScheme.darkColorScheme,
  );
}
