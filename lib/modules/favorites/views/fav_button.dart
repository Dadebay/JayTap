import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/favorites/controllers/favorites_controller.dart';
import 'package:jaytap/shared/extensions/extensions.dart';

class FavButton extends StatelessWidget {
  final int itemId;

  const FavButton({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    final FavoritesController favoritesController =
        Get.find<FavoritesController>();
    final bool themeValue = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final isFavorite = favoritesController.isFavorite(itemId);

      return GestureDetector(
        onTap: () {
          favoritesController.toggleFavorite(itemId);
        },
        child: Container(
          padding: EdgeInsets.all(6),
          child: Icon(
            isFavorite ? IconlyBold.heart : IconlyLight.heart,
            color: isFavorite
                ? ColorConstants.redColor
                : themeValue
                    ? context.whiteColor
                    : context.whiteColor,
            size: 23,
          ),
        ),
      );
    });
  }
}
