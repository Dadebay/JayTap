import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';
import 'package:jaytap/shared/extensions/extensions.dart';

class MapDrawingControls extends StatelessWidget {
  final SearchControllerMine controller;

  const MapDrawingControls({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: controller.isLoadingLocation.value
                    ? CircularProgressIndicator(strokeWidth: 2)
                    : Image.asset(
                        IconConstants.findMe,
                        color: Theme.of(context).colorScheme.onSurface,
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
            if (isCurrentlyDrawing) {
              return GestureDetector(
                onTap: () => controller.manuallyFinishDrawing(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.2),
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.check,
                      color: Theme.of(context).colorScheme.onPrimary, size: 24),
                ),
              );
            }

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
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(IconlyLight.delete,
                      color: Theme.of(context).colorScheme.onPrimary, size: 24),
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
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Image.asset(IconConstants.selectionIcon,
                    color: controller.isDrawingMode.value
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    width: 24,
                    height: 24),
              ),
            );
          }),
          GestureDetector(
            onTap: () {
              // controller.clearDrawing();
              controller.filteredProperties.assignAll(controller.properties);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Icon(IconlyLight.delete, color: Colors.black, size: 24),
            ),
          )
        ],
      ),
    );
  }
}
