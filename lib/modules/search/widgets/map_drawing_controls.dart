import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';
import 'package:jaytap/shared/extensions/extensions.dart';

class MapDrawingControls extends StatelessWidget {
  final SearchControllerMine controller;

  // RE-ADD the constructor
  const MapDrawingControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      right: 12,
      top: 0,
      bottom: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() {
            return GestureDetector(
              onTap: controller.isLoadingLocation.value
                  ? null
                  : () => controller.findAndMoveToCurrentUserLocation(),
              child: Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDarkMode ? context.blackColor : context.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                // Yükleniyorsa progress indicator, değilse ikonu göster
                child: controller.isLoadingLocation.value
                    ? CircularProgressIndicator(strokeWidth: 2)
                    : Image.asset(
                        IconConstants.findMe,
                        color: isDarkMode
                            ? context.whiteColor
                            : context.blackColor.withOpacity(.7),
                        width: 24,
                        height: 24,
                      ),
              ),
            );
          }),
          Obx(() {
            final bool isPolygonDrawn = controller.polygons.isNotEmpty;
            final bool isCurrentlyDrawing = controller.isDrawingMode.value &&
                controller.drawingPoints.isNotEmpty;

            // YENİ: Eğer kullanıcı aktif olarak çizim yapıyorsa, bitirme düğmesini göster.
            if (isCurrentlyDrawing) {
              return GestureDetector(
                onTap: () => controller.manuallyFinishDrawing(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.green, // Bittiğini belli eden yeşil renk
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.check, color: Colors.white, size: 24),
                ),
              );
            }

            // Eğer bir alan zaten çizilmişse, silme düğmesini göster.
            if (isPolygonDrawn) {
              return GestureDetector(
                onTap: () {
                  controller.clearDrawing();
                  controller.filteredProperties
                      .assignAll(controller.properties);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child:
                      Icon(IconlyLight.delete, color: Colors.white, size: 24),
                ),
              );
            }

            return GestureDetector(
              onTap: () => controller.goToDrawingPage(),
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: controller.isDrawingMode.value
                      ? Colors.blue
                      : isDarkMode
                          ? context.blackColor
                          : context.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Image.asset(IconConstants.selectionIcon,
                    color: controller.isDrawingMode.value
                        ? context.whiteColor
                        : isDarkMode
                            ? context.whiteColor
                            : context.blackColor,
                    width: 24,
                    height: 24),
              ),
            );
          }),
        ],
      ),
    );
  }
}
