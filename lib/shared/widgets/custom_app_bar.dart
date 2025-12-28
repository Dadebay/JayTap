import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:kartal/kartal.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool? centerTitle;
  final bool? showElevation;
  final Widget? actionButton;
  final Widget? leadingButton;
  final VoidCallback? onBack;

  CustomAppBar(
      {required this.title,
      required this.showBackButton,
      this.centerTitle,
      this.showElevation,
      this.leadingButton,
      this.actionButton,
      this.onBack});
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0.0,
      elevation: showElevation == true ? 1.0 : 0.0,
      shadowColor:
          isDarkMode ? context.blackColor : context.greyColor.withOpacity(.3),
      centerTitle: centerTitle ?? true,
      backgroundColor: isDarkMode ? context.blackColor : context.whiteColor,
      leadingWidth: centerTitle == false
          ? 10.0
          : (leadingButton != null && showBackButton ? 100 : 80),
      leading: showBackButton
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    if (onBack != null) {
                      onBack!();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(
                    IconlyLight.arrowLeftCircle,
                    size: 22,
                  ),
                ),
                if (leadingButton != null) leadingButton!,
              ],
            )
          : leadingButton ?? const SizedBox.shrink(),
      title: Text(
        title.tr,
        style: context.general.textTheme.headlineMedium!
            .copyWith(fontSize: 20.sp, fontWeight: FontWeight.w500),
      ),
      actions: [
        actionButton ?? const SizedBox.shrink(),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
