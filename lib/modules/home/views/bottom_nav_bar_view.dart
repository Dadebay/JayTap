import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/constants/list_constants.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/auth/views/login_view.dart';
import 'package:jaytap/modules/chat/views/chat_view.dart';
import 'package:jaytap/modules/favorites/views/favorites_view.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/home/views/custom_bottom_nav_extension.dart';
import 'package:jaytap/modules/home/views/home_view.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';
import 'package:jaytap/modules/search/views/search_view.dart';
import 'package:jaytap/modules/user_profile/views/settings_view.dart';
import 'package:jaytap/shared/widgets/custom_app_bar.dart';
import 'package:upgrader/upgrader.dart';

class BottomNavBar extends StatefulWidget {
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final SearchControllerMine searchController = Get.put(SearchControllerMine());
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIN = AuthStorage().isLoggedIn;
    List<Widget> pages = [HomeView(), SearchView(), ChatView(), FavoritesView(), isLoggedIN ? SettingsView() : LoginView()];

    return UpgradeAlert(
      upgrader: Upgrader(languageCode: 'ru'),
      dialogStyle: Platform.isAndroid ? UpgradeDialogStyle.material : UpgradeDialogStyle.cupertino,
      child: Obx(() => Scaffold(
            appBar: PreferredSize(
              // preferredSize: Size.fromHeight(homeController.bottomNavBarSelectedIndex.value == 3 ? 60 : 0),
              preferredSize: Size.fromHeight(0),
              child: CustomAppBar(
                title: ListConstants.pageNames[homeController.bottomNavBarSelectedIndex.value],
                showBackButton: false,
              ),
            ),
            body: pages[homeController.bottomNavBarSelectedIndex.value],
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: homeController.bottomNavBarSelectedIndex.value,
              onTap: (index) {
                if (index == 1) {
                  searchController.fetchProperties();
                }
                homeController.changePage(index);
              },
              selectedIcons: ListConstants.selectedIcons,
              unselectedIcons: ListConstants.mainIcons,
            ),
          )),
    );
  }
}
