import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';
import 'package:jaytap/modules/search/views/filter_view.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:kartal/kartal.dart';

class SearchAppBar extends StatelessWidget {
  final SearchControllerMine controller;
  final TextEditingController _searchController = TextEditingController();

  SearchAppBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: isDarkMode ? context.blackColor : context.whiteColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.greyColor.withOpacity(.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: context.general.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Gözle...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14.sp,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.w),
            child: Icon(
              IconlyLight.search,
              color: Colors.grey[500],
              size: 20.sp,
            ),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              Get.to(() => FilterView());
            },
            icon: Icon(
              IconlyLight.filter,
              color: context.greyColor,
              size: 20.sp,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }
}
