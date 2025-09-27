import 'package:flutter/material.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';

final class CustomDarkTheme {
  final ThemeData themeData = ThemeData(
    useMaterial3: true,
    appBarTheme: const AppBarTheme(),
    fontFamily: 'PlusJakartaSans',
    colorScheme: CustomColorScheme.darkColorScheme,
  );
}
