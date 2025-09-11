// ignore_for_file: file_names, always_use_package_imports

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/modules/home/views/bottom_nav_bar_view.dart';
import 'package:jaytap/shared/dialogs/dialogs_utils.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/sizes/image_sizes.dart';

class ConnectionCheckView extends StatefulWidget {
  const ConnectionCheckView({super.key});

  @override
  _ConnectionCheckViewState createState() => _ConnectionCheckViewState();
}

class _ConnectionCheckViewState extends State<ConnectionCheckView> {
  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  void checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        await Future.delayed(
            const Duration(seconds: 4), () => Get.offAll(() => BottomNavBar()));
      }
    } on SocketException catch (_) {
      DialogUtils.showNoConnectionDialog(
        onRetry: () {
          Navigator.of(context).pop();
          checkConnection();
        },
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.primaryColor,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              IconConstants.logo,
              width: WidgetSizes.size320.value,
              height: WidgetSizes.size320.value,
            ),
            CircularProgressIndicator(
              color: context.whiteColor,
            )
          ],
        ),
      ),
    );
  }
}
