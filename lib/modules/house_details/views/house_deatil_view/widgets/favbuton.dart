import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/favorites/controllers/favorites_controller.dart';

class FavButtonDetail extends StatelessWidget {
  final int itemId;

  const FavButtonDetail({
    super.key,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    final FavoritesController favoritesController =
        Get.find<FavoritesController>();

    return Obx(() {
      final isFavorite = favoritesController.isFavorite(itemId);

      return IconButton(
        onPressed: () {
          favoritesController.toggleFavorite(itemId);
        },
        padding: EdgeInsets.zero,
        icon: Icon(
          isFavorite ? IconlyBold.heart : IconlyLight.heart,
          color: isFavorite ? const Color(0xFFE91E63) : Colors.black,
          size: 24,
        ),
      );
    });
  }
}
