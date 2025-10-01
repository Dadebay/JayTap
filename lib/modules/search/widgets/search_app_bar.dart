import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';
import 'package:jaytap/modules/search/views/filter_view.dart';
import 'package:kartal/kartal.dart';

class SearchAppBar extends StatefulWidget {
  final SearchControllerMine controller;
  final bool showBackButton;
  final VoidCallback? onBack;

  const SearchAppBar({super.key, required this.controller, this.showBackButton = false, this.onBack});

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          if (widget.showBackButton)
            IconButton(
              icon: Icon(IconlyLight.arrowLeftCircle, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20.sp),
              onPressed: () {
                widget.onBack?.call();
              },
            ),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: context.general.textTheme.bodyMedium,
              onSubmitted: (value) {
                widget.controller.searchByAddress(value);
              },
              decoration: InputDecoration(
                hintText: 'search_hint'.tr,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14.sp,
                ),
                prefixIcon: GestureDetector(
                  onTap: () {
                    widget.controller.searchByAddress(_searchController.text);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Icon(
                      IconlyLight.search,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20.sp,
                    ),
                  ),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    Get.to(() => FilterView());
                  },
                  icon: Icon(
                    IconlyLight.filter,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          ),
        ],
      ),
    );
  }
}
