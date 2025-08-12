// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/shared/extensions/extensions.dart';

class ProfilButton extends StatelessWidget {
  final String name;
  final Function() onTap;
  final IconData icon;
  const ProfilButton({
    required this.name,
    required this.onTap,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      selectedTileColor: Colors.transparent,
      focusColor: Colors.transparent,
      tileColor: Colors.transparent,
      selectedColor: context.whiteColor,
      title: Text(
        name.tr,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400, fontSize: 15.sp),
        maxLines: 1,
      ),
      leading: Container(
        width: 30,
        height: 30,
        child: Icon(
          icon,
          color: isDarkMode ? context.whiteColor : context.blackColor.withOpacity(.7),
          size: 25,
        ),
      ),
      trailing: Icon(
        IconlyLight.arrowRightCircle,
        size: 20,
        color: isDarkMode ? context.whiteColor.withOpacity(.5) : context.blackColor.withOpacity(.7),
      ),
    );
  }
}
