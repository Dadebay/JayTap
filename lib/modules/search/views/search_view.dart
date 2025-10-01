import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/modules/search/views/drawing_view.dart';
import 'package:jaytap/modules/search/views/realted_houses.dart';
import 'package:jaytap/modules/search/widgets/map_drawing_controls.dart';
import 'package:jaytap/shared/extensions/packages.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/search_app_bar.dart';

class SearchView extends GetView<SearchControllerMine> {
  final List<int>? propertyIds;

  SearchView({super.key, this.propertyIds});

  @override
  SearchControllerMine get controller =>
      Get.put(SearchControllerMine(initialPropertyIds: propertyIds),
          permanent: true);

  Stack _body(BuildContext context, bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Obx(() {
          if (controller.isLoading.value) {
            return CustomWidgets.loader();
          }
          return GestureDetector(
            onScaleStart: controller.onScaleStart,
            onScaleUpdate: controller.onScaleUpdate,
            onPanStart:
                controller.isDrawingMode.value ? controller.onPanStart : null,
            onPanUpdate:
                controller.isDrawingMode.value ? controller.onPanUpdate : null,
            onPanEnd:
                controller.isDrawingMode.value ? controller.onPanEnd : null,
            child: Stack(
              children: [
                Obx(() {
                  final position = controller.userLocation.value;
                  if (position != null && controller.isMapReady) {
                    Future.microtask(() {
                      controller.mapController
                          .move(position, controller.currentZoom.value);
                    });
                  }
                  return ColorFiltered(
                    colorFilter: isDarkMode
                        ? ColorFilter.mode(
                            Colors.black.withOpacity(0.6), BlendMode.darken)
                        : ColorFilter.mode(
                            Colors.transparent, BlendMode.srcOver),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: FlutterMap(
                        mapController: controller.mapController,
                        options: MapOptions(
                          initialCenter: controller.currentPosition.value,
                          initialZoom: controller.currentZoom.value,
                          onPositionChanged: (camera, hasGesture) {
                            controller.mapRotation.value = camera.rotation;
                            controller.refreshMask.value++;
                          },
                          interactionOptions: InteractionOptions(
                              flags: controller.isDrawingMode.value
                                  ? InteractiveFlag.none
                                  : InteractiveFlag.all),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: ApiConstants.mapUrl,
                            maxZoom: 25,
                            minZoom: 5,
                            userAgentPackageName: 'com.gurbanov.jaytap',
                          ),
                          Obx(() => PolylineLayer(
                              polylines: controller.polylines.toList())),
                          Obx(() => PolygonLayer(
                              polygons: controller.polygons.toList())),
                          Obx(() {
                            Map<String, List<Marker>> markersByPosition = {};
                            controller.filteredProperties
                                .where((property) =>
                                    property.lat != null &&
                                    property.long != null)
                                .forEach((property) {
                              String key = '${property.lat},${property.long}';
                              String title = property.category ??
                                  property.subcat ??
                                  'satlyk';
                              Marker marker = Marker(
                                point: LatLng(property.lat!, property.long!),
                                width: 120,
                                height: 40,
                                child: CustomWidgets.marketWidget(
                                  context: context,
                                  price: property.price?.toString() ?? 'N/A',
                                  houseID: property.id,
                                  type: title.toLowerCase(),
                                ),
                              );
                              markersByPosition
                                  .putIfAbsent(key, () => [])
                                  .add(marker);
                            });

                            List<Marker> adjustedMarkers = [];
                            markersByPosition.forEach((key, markers) {
                              if (markers.length > 1) {
                                for (int i = 0; i < markers.length; i++) {
                                  double offsetLat =
                                      0.0001 * (i - (markers.length - 1) / 2);
                                  double offsetLong =
                                      0.0001 * (i - (markers.length - 1) / 2);
                                  LatLng newPoint = LatLng(
                                    markers[i].point.latitude + offsetLat,
                                    markers[i].point.longitude + offsetLong,
                                  );
                                  adjustedMarkers.add(Marker(
                                    point: newPoint,
                                    width: markers[i].width,
                                    height: markers[i].height,
                                    child: markers[i].child,
                                  ));
                                }
                              } else {
                                adjustedMarkers.add(markers.first);
                              }
                            });

                            return MarkerLayer(
                              markers: adjustedMarkers,
                            );
                          }),
                          Obx(() {
                            if (controller.userLocation.value != null) {
                              return MarkerLayer(
                                markers: [
                                  Marker(
                                    point: controller.userLocation.value!,
                                    width: 15,
                                    height: 15,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              spreadRadius: 1)
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Container();
                          }),
                        ],
                      ),
                    ),
                  );
                }),
                Obx(() {
                  if (controller.polygons.isNotEmpty) {
                    controller.refreshMask.value;
                    return IgnorePointer(
                      ignoring: true,
                      child: CustomPaint(
                        painter: MapMaskPainter(
                          controller.polygons.toList(),
                          controller.mapController,
                        ),
                        size: Size.infinite,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          );
        }),
        Positioned(
          bottom: 15.0,
          left: 15,
          child: ElevatedButton(
            onPressed: () {
              final List<int> currentIds = controller.filteredProperties
                  .map((property) => property.id)
                  .toList();
              print("Filtered Properties: $currentIds");
              controller.relatedHouseIds.assignAll(currentIds);
              controller.showRelatedHousesView.value = true;
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4, top: 4),
                  child: Icon(Icons.list, size: 25, color: Colors.grey),
                ),
                Text(
                  "relatedHouses".tr,
                  style:
                      context.textTheme.bodyMedium!.copyWith(fontSize: 16.sp),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 15.0,
          right: 15,
          child: ElevatedButton(
            onPressed: () {
              controller.clearDrawing();
              controller.fetchProperties();
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(Icons.delete, color: Colors.grey),
                ),
                Text(
                  "clear_filter".tr,
                  style:
                      context.textTheme.bodyMedium!.copyWith(fontSize: 16.sp),
                ),
              ],
            ),
          ),
        ),
        MapDrawingControls(controller: controller),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      return Scaffold(
        appBar: controller.showRelatedHousesView.value
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: SearchAppBar(
                  controller: controller,
                  showBackButton: false,
                  onBack: null,
                ),
              ),
        body: controller.showRelatedHousesView.value
            ? RealtedHousesView(
                propertyIds: controller.relatedHouseIds.toList(),
                onBack: () => controller.showRelatedHousesView.value = false,
              )
            : _body(context, isDarkMode),
      );
    });
  }
}
