// ignore_for_file: file_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:kartal/kartal.dart';

class AgreeButton extends StatelessWidget {
  final Function() onTap;
  final String text;
  final bool? showBorder;
  final RxBool? isLoading;

  AgreeButton({
    required this.onTap,
    required this.text,
    this.showBorder,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: _animatedContainer(context));
  }

  Widget _animatedContainer(BuildContext context) {
    final loading = isLoading?.value ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      margin: context.padding.verticalNormal.copyWith(top: 10, bottom: 10),
      padding: context.padding.normal.copyWith(top: 10, bottom: 10),
      width: loading ? 60.w : Get.size.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: showBorder == true ? Colors.transparent : context.primaryColor,
        border: Border.all(color: context.primaryColor),
        borderRadius: BorderRadius.circular(15),
      ),
      child: loading
          ? SizedBox(
              width: 34.w,
              height: 25.h,
              child: const CircularProgressIndicator(color: Colors.white),
            )
          : Text(
              text.tr,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: context.general.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: showBorder == true ? context.primaryColor : Colors.white,
              ),
            ),
    );
  }
}

class GradientButton extends StatelessWidget {
  const GradientButton({super.key, required this.onTap, required this.text});
  final Function() onTap;
  final String text;
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.padding.normal.copyWith(top: 13, bottom: 13),
        width: Get.size.width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDarkMode ? context.blackColor : null,
          boxShadow: isDarkMode
              ? [
                  BoxShadow(
                    color: context.whiteColor.withOpacity(.5),
                    blurRadius: 5,
                  ),
                ]
              : [
                  BoxShadow(
                    color: context.primaryColor,
                    blurRadius: 2,
                  ),
                ],
          gradient: isDarkMode
              ? null
              : LinearGradient(
                  colors: [
                    Color(0xff009EFF),
                    Color(0xff49B2ED),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text.tr,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: context.general.textTheme.titleLarge!.copyWith(
            color: context.whiteColor,
          ),
        ),
      ),
    );
  }
}

class TransparentColorButton extends StatelessWidget {
  const TransparentColorButton({super.key, required this.onTap, required this.icon, required this.text});
  final Function() onTap;
  final String text;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.padding.normal.copyWith(top: 13, bottom: 13),
        width: Get.size.width,
        margin: EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDarkMode ? context.blackColor : context.primaryColor.withOpacity(.3),
          boxShadow: isDarkMode
              ? [
                  BoxShadow(
                    color: context.whiteColor.withOpacity(.5),
                    blurRadius: 5,
                  ),
                ]
              : [],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.only(right: 10), child: Icon(icon, size: 18.sp, color: context.primaryColor)),
            Text(
              text.tr,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: context.general.textTheme.titleLarge!.copyWith(fontSize: 16.sp, color: context.primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
