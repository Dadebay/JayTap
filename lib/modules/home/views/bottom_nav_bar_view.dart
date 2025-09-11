import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/constants/list_constants.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
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
  DateTime? lastPressed;

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIN = AuthStorage().isLoggedIn;
    List<Widget> pages = [
      HomeView(),
      SearchView(),
      ChatView(),
      FavoritesView(),
      isLoggedIN ? SettingsView() : LoginView()
    ];

    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        final maxDuration = Duration(seconds: 2);
        final isWarning =
            lastPressed == null || now.difference(lastPressed!) > maxDuration;

        if (isWarning) {
          lastPressed = DateTime.now();
          final snackBar = SnackBar(
            content: Text(
              'press_again_to_exit'.tr,
              style: TextStyle(color: Colors.white),
            ),
            duration: maxDuration,
            backgroundColor: Colors.black.withOpacity(0.5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          );

          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(snackBar);
          return false;
        } else {
          _showExitDialog();
          return true;
        }
      },
      child: UpgradeAlert(
        upgrader: Upgrader(languageCode: 'ru'),
        dialogStyle: Platform.isAndroid
            ? UpgradeDialogStyle.material
            : UpgradeDialogStyle.cupertino,
        child: Obx(() => Scaffold(
              // backgroundColor: ColorConstants.whiteColor,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(
                    homeController.bottomNavBarSelectedIndex.value == 3
                        ? kToolbarHeight
                        : 0),
                child: CustomAppBar(
                  title: ListConstants.pageNames[
                      homeController.bottomNavBarSelectedIndex.value],
                  showBackButton: false,
                  centerTitle: false,
                ),
              ),
              body: pages[homeController.bottomNavBarSelectedIndex.value],
              bottomNavigationBar: CustomBottomNavBar(
                currentIndex: homeController.bottomNavBarSelectedIndex.value,
                onTap: (index) async {
                  homeController.changePage(index);
                },
                selectedIcons: ListConstants.selectedIcons,
                unselectedIcons: ListConstants.mainIcons,
              ),
            )),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.exit_to_app, size: 50, color: Colors.blue),
                SizedBox(height: 15),
                Text(
                  'exit_app'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'exit_app_confirmation'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('no'.tr),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('yes'.tr),
                        onPressed: () {
                          exit(0);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
