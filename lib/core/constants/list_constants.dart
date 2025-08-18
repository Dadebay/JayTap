// ignore_for_file: avoid_slow_async_io

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:jaytap/modules/chat/views/chat_view.dart';
import 'package:jaytap/modules/favorites/views/favorites_view.dart';
import 'package:jaytap/modules/home/views/home_view.dart';
import 'package:jaytap/modules/search/views/search_view.dart';
import 'package:jaytap/modules/user_profile/views/settings_view.dart';
import 'package:jaytap/modules/user_profile/views/user_profile_view.dart';

@immutable
class ListConstants {
  static List<String> pageNames = [
    'home',
    'search',
    'chat',
    'favorites',
    'settings',
  ];
  static List<IconData> mainIcons = [IconlyLight.home, IconlyLight.search, IconlyLight.chat, IconlyLight.heart, IconlyLight.profile];
  static List<IconData> selectedIcons = [IconlyBold.home, IconlyBold.search, IconlyBold.chat, IconlyBold.heart, IconlyBold.profile];
}
