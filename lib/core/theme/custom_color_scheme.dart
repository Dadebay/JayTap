// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

final class CustomColorScheme {
  CustomColorScheme._();

  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: ColorConstants.kPrimaryColor,
    onPrimary: Colors.white,
    secondary: ColorConstants.kSecondaryColor,
    onSecondary: Colors.white,
    surface: ColorConstants.whiteColor,
    onSurface: ColorConstants.blackColor,
    outline: ColorConstants.greyColor,
    error: ColorConstants.redColor,
    onError: Colors.white,
    errorContainer: ColorConstants.redColorwithOpacity,
    onErrorContainer: ColorConstants.redColor,
    shadow: Colors.black,
    tertiary: ColorConstants.purpleColor,
    tertiaryContainer: ColorConstants.purpleColorwithOpacity,
    inversePrimary: ColorConstants.kPrimaryColor2,
    surfaceTint: ColorConstants.blueColorwithOpacity,
    scrim: Colors.black,
    onSurfaceVariant: Colors.grey,
    inverseSurface: Color(0xff313033),
    onInverseSurface: Colors.white,
    primaryContainer: Color(0xFFEADDFF),
    onPrimaryContainer: Color(0xFF21005D),
    secondaryContainer: Color(0xFFE8DEF8),
    onSecondaryContainer: Color(0xFF1D192B),
    background: Color(0xFFCAC4D0),
    onBackground: Color(0xFFCAC4D0),
  );

  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xff43A0D9),
    onPrimary: ColorConstants.whiteColor,
    secondary: ColorConstants.kSecondaryColor,
    onSecondary: ColorConstants.blackColor,
    primaryContainer: ColorConstants.kPrimaryColor2,
    onPrimaryContainer: ColorConstants.whiteColor,
    secondaryContainer: ColorConstants.greenColorwithOpacity,
    onSecondaryContainer: ColorConstants.blackColor,
    tertiary: ColorConstants.purpleColor,
    onTertiary: ColorConstants.whiteColor,
    tertiaryContainer: ColorConstants.purpleColorwithOpacity,
    onTertiaryContainer: ColorConstants.blackColor,
    error: ColorConstants.redColor,
    onError: ColorConstants.whiteColor,
    errorContainer: ColorConstants.redColorwithOpacity,
    onErrorContainer: ColorConstants.whiteColor,
    surface: Color(0xFF121212),
    onSurface: ColorConstants.whiteColor,
    outline: ColorConstants.greyColor,
    outlineVariant: Color(0xFF4B4B4B),
    shadow: ColorConstants.blackColor,
    surfaceTint: ColorConstants.blueColorwithOpacity,
    scrim: ColorConstants.blackColor,
    inverseSurface: ColorConstants.whiteColor,
    onInverseSurface: ColorConstants.blackColor,
    inversePrimary: ColorConstants.kPrimaryColor2,
    // outlineVariant: Color(0xFFCAC4D0),
    background: Color(0xFFCAC4D0), onBackground: Color(0xFFCAC4D0),
  );
}

@immutable
class ColorConstants {
  const ColorConstants._();

  static const Color kPrimaryColor = Color(0xff43A0D9);
  static const Color kPrimaryColor2 = Color(0xff009EFF);
  static const Color kSecondaryColor = Color(0xff009B00);
  static const Color kPrettyBlack = Color(0xff1A1A1A);
  static const Color kPrettyBlack2 = Color(0xFF1d1d1b);
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Color(0xff1A1A1A);
  static const Color greyColor = Colors.grey;

  static const Color blueColorwithOpacity = Color(0xffcde7fc);

  static const Color greenColor = kSecondaryColor;
  static const Color greenColorwithOpacity = Color.fromARGB(255, 14, 120, 0);
  static const Color greenColorwithOpacity2 = Color(0xffdcffce);

  static const Color yellowColorwithOpacity = Color(0xfffedb00);

  static const Color purpleColor = Color(0xffbf7ef3);
  static const Color purpleColorwithOpacity = Color(0xffe6cefe);

  static const Color greyColorwithOpacity = Color(0xfff2f5fc);

  static const Color redColorwithOpacity = Color(0x00ff7272);
  static const Color redColor = Colors.red;
  static const Color premiumColor = Color(0xfffed42a);
}
