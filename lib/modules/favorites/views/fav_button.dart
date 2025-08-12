// lib/modules/favorites/views/fav_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/favorites/controllers/favorites_controller.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:kartal/kartal.dart';

class FavButton extends StatelessWidget {
  final int itemId;

  const FavButton({
    // const ekle
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    // Controller'ı build metodu içinde bulalım
    final FavoritesController favoritesController = Get.find<FavoritesController>();
    final bool themeValue = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final isFavorite = favoritesController.isFavorite(itemId);

      return GestureDetector(
        onTap: () {
          // Controller'daki yeni toggle metodunu çağır
          favoritesController.toggleFavorite(itemId);
        },
        child: Container(
          padding: context.padding.low,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: themeValue ? context.blackColor.withOpacity(.6) : context.whiteColor.withOpacity(.9),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            isFavorite ? IconlyBold.heart : IconlyLight.heart,
            color: isFavorite
                ? ColorConstants.redColor
                : themeValue
                    ? context.whiteColor
                    : context.blackColor.withOpacity(.8),
            size: 24.sp,
          ),
        ),
      );
    });
  }
}
