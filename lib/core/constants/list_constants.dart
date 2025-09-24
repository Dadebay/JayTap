// ignore_for_file: avoid_slow_async_io

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:hugeicons/hugeicons.dart';

@immutable
class ListConstants {
  static List<String> pageNames = [
    'home',
    'search',
    'chat',
    'favorites',
    'settings',
  ];
  static List<IconData> mainIcons = [HugeIcons.strokeRoundedHome09, IconlyLight.search, IconlyLight.chat, IconlyLight.heart, IconlyLight.profile];
  static List<IconData> selectedIcons = [HugeIcons.strokeRoundedHome09, IconlyBold.search, IconlyBold.chat, IconlyBold.heart, IconlyBold.profile];
}
