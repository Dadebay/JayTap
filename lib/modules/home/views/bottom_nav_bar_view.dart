import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/constants/list_constants.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/home/views/custom_bottom_nav_extension.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';
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
    return UpgradeAlert(
      upgrader: Upgrader(languageCode: 'ru'),
      dialogStyle: Platform.isAndroid ? UpgradeDialogStyle.material : UpgradeDialogStyle.cupertino,
      child: Obx(() => Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(homeController.bottomNavBarSelectedIndex.value == 3 ? 60 : 0),
              child: CustomAppBar(
                title: ListConstants.pageNames[homeController.bottomNavBarSelectedIndex.value],
                showBackButton: false,
              ),
            ),
            body: ListConstants.pages[homeController.bottomNavBarSelectedIndex.value],
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: homeController.bottomNavBarSelectedIndex.value,
              onTap: (index) {
                print(index);
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
