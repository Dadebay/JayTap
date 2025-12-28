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
import 'package:jaytap/modules/search/views/search_view.dart';
import 'package:jaytap/modules/user_profile/views/settings_view.dart';
import 'package:jaytap/shared/dialogs/dialogs_utils.dart';
import 'package:jaytap/shared/widgets/custom_app_bar.dart';
import 'package:upgrader/upgrader.dart';

class BottomNavBar extends StatefulWidget {
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final HomeController homeController = Get.find<HomeController>();
  final AuthStorage authStorage = Get.find<AuthStorage>(); // Get AuthStorage instance
  DateTime? lastPressed;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        final maxDuration = Duration(seconds: 2);
        final isWarning = lastPressed == null || now.difference(lastPressed!) > maxDuration;

        if (isWarning) {
          lastPressed = DateTime.now();
          final snackBar = SnackBar(
            content: Text(
              'press_again_to_exit'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            duration: maxDuration,
            backgroundColor: Colors.black.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          );

          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(snackBar);
          return false;
        } else {
          DialogUtils().showExitDialog(context);
          return true;
        }
      },
      child: UpgradeAlert(
        upgrader: Upgrader(languageCode: 'ru'),
        dialogStyle: Platform.isAndroid ? UpgradeDialogStyle.material : UpgradeDialogStyle.cupertino,
        child: Obx(() {
          final String token = authStorage.token ?? '';
          print("isLoggedIN: $token");

          List<Widget> pages = [HomeView(), SearchView(), ChatView(), FavoritesView(), token.isNotEmpty ? SettingsView() : LoginView()];

          return SafeArea(
            top: false,
            bottom: Platform.isAndroid ? true : false,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(homeController.bottomNavBarSelectedIndex.value == 3 ? kToolbarHeight : 0),
                child: CustomAppBar(
                  title: ListConstants.pageNames[homeController.bottomNavBarSelectedIndex.value],
                  showBackButton: false,
                  centerTitle: false,
                ),
              ),
              body: IndexedStack(
                index: homeController.bottomNavBarSelectedIndex.value,
                children: pages,
              ),
              bottomNavigationBar: CustomBottomNavBar(
                currentIndex: homeController.bottomNavBarSelectedIndex.value,
                onTap: (index) async {
                  homeController.changePage(index);
                },
                selectedIcons: ListConstants.selectedIcons,
                unselectedIcons: ListConstants.mainIcons,
                pageNames: ListConstants.pageNames,
              ),
            ),
          );
        }),
      ),
    );
  }
}
