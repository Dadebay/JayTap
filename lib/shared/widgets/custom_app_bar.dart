import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:kartal/kartal.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool? showElevation;
  final Widget? actionButton;
  final Widget? leadingButton;

  CustomAppBar({required this.title, required this.showBackButton, this.showElevation, this.leadingButton, this.actionButton});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0.0,
      elevation: showElevation == true ? 1.0 : 0.0,
      shadowColor: context.greyColor.withOpacity(.3),
      centerTitle: true,
      // backgroundColor: isDarkMode ? context.blackColor : context.whiteColor,
      leading: showBackButton
          ? IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Icon(
                IconlyLight.arrowLeftCircle,
                size: 22,
              ),
            )
          : leadingButton ?? const SizedBox.shrink(),
      title: Text(
        title.tr,
        style: context.general.textTheme.headlineMedium!.copyWith(fontSize: 22.sp),
      ),
      actions: [
        actionButton ?? const SizedBox.shrink(),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
