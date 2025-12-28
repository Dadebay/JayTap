import 'dart:ui' as ui;
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/modules/search/views/drawing_view.dart';
import 'package:jaytap/modules/search/views/realted_houses.dart';
import 'package:jaytap/modules/search/widgets/map_drawing_controls.dart';
import 'package:jaytap/shared/extensions/packages.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/search_app_bar.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:jaytap/modules/search/controllers/filter_controller.dart';

class SearchView extends GetView<SearchControllerMine> {
  final List<int>? propertyIds;

  SearchView({super.key, this.propertyIds});

  @override
  SearchControllerMine get controller => Get.put(SearchControllerMine(initialPropertyIds: propertyIds), permanent: true);

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
            onPanStart: controller.isDrawingMode.value ? controller.onPanStart : null,
            onPanUpdate: controller.isDrawingMode.value ? controller.onPanUpdate : null,
            onPanEnd: controller.isDrawingMode.value ? controller.onPanEnd : null,
            child: Stack(
              children: [
                Obx(() {
                  final position = controller.userLocation.value;
                  if (position != null && controller.shouldCenterMap.value) {
                    Future.microtask(() {
                      controller.mapController.move(position, controller.currentZoom.value);
                      controller.shouldCenterMap.value = false;
                    });
                  }
                  return ColorFiltered(
                    colorFilter: isDarkMode ? ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken) : ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: FlutterMap(
                        mapController: controller.mapController,
                        options: MapOptions(
                          initialCenter: controller.currentPosition.value,
                          initialZoom: controller.currentZoom.value,
                          onPositionChanged: (camera, hasGesture) {
                            controller.currentZoom.value = camera.zoom;
                            controller.mapRotation.value = camera.rotation;
                            controller.refreshMask.value++;
                          },
                          interactionOptions: InteractionOptions(flags: controller.isDrawingMode.value ? InteractiveFlag.none : InteractiveFlag.all),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: ApiConstants.mapUrl,
                            maxZoom: 25,
                            minZoom: 5,
                            keepBuffer: 8,
                            panBuffer: 2,
                            userAgentPackageName: 'com.gurbanov.jaytap',
                          ),
                          Obx(() => PolylineLayer(polylines: controller.polylines.toList())),
                          Obx(() => PolygonLayer(polygons: controller.polygons.toList())),
                          Obx(() {
                            final zoom = controller.currentZoom.value;
                            final markers = controller.filteredProperties.where((property) => property.lat != null && property.long != null).map((property) {
                              final title = property.category ?? property.subcat ?? 'satlyk';
                              return Marker(
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
                            }).toList();

                            if (zoom >= 17) {
                              return MarkerClusterLayerWidget(
                                options: MarkerClusterLayerOptions(
                                  spiderfyCluster: true,
                                  spiderfyCircleRadius: 60,
                                  spiderfySpiralDistanceMultiplier: 2,
                                  maxClusterRadius: 45,
                                  size: const Size(30, 30),
                                  onClusterTap: (cluster) {
                                    final currentZoom = controller.mapController.camera.zoom;
                                    controller.mapController.move(
                                      cluster.bounds.center,
                                      currentZoom,
                                    );
                                  },
                                  markers: markers,
                                  builder: (context, markers) {
                                    Color clusterColor = Colors.blue;

                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: clusterColor,
                                      ),
                                      child: Center(
                                        child: Text(
                                          markers.length.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }

                            return MarkerLayer(markers: markers);
                          }),
                          // Ad Banner Markers
                          Obx(() {
                            final bannerMarkers = controller.adBanners.where((banner) => banner.lat != null && banner.long != null).map((banner) {
                              return Marker(
                                point: LatLng(banner.lat!, banner.long!),
                                width: 45,
                                height: 55,
                                child: GestureDetector(
                                  onTap: () => controller.showAdBannerDetail(banner),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Location pin background shape
                                      Positioned(
                                        top: 0,
                                        child: Container(
                                          width: 45,
                                          height: 55,
                                          child: CustomPaint(
                                            painter: LocationPinPainter(color: Color(0xFF4A9FE8)),
                                          ),
                                        ),
                                      ),
                                      // Circular image inside
                                      Positioned(
                                        top: 6,
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: '${ApiConstants.baseUrl}${banner.img.startsWith('/') ? banner.img.substring(1) : banner.img}',
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => Container(
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 12,
                                                    height: 12,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A9FE8)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => Container(
                                                color: Colors.grey[300],
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey[600],
                                                  size: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList();
                            return MarkerLayer(markers: bannerMarkers);
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
                                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1)],
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
          top: 15.0,
          left: 15,
          right: 15,
          child: Obx(() {
            if (!controller.showRelatedHousesView.value) {
              return SearchAppBar(
                controller: controller,
                showBackButton: false,
                onBack: null,
              );
            }
            return const SizedBox.shrink();
          }),
        ),
        Positioned(
          bottom: 10.0,
          left: 13,
          child: ElevatedButton(
            onPressed: () {
              controller.updateRelatedHouses();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffE2F3FC).withOpacity(.7),
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(IconlyLight.document, size: 25, color: Colors.black),
                ),
                Text(
                  "relatedHouses".tr,
                  style: context.textTheme.bodyMedium!.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 10.0,
          right: 10,
          child: ElevatedButton(
            onPressed: () async {
              controller.clearDrawing();
              if (Get.isRegistered<FilterController>()) {
                final filterController = Get.find<FilterController>();
                filterController.resetFilters(); // Bu metod zaten searchController.setFilterData() çağırıyor
              } else {
                await controller.fetchProperties();
              }

              controller.syncRelatedHouses();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffff6242).withOpacity(.6),
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4, bottom: 2),
                  child: Icon(IconlyBold.delete, color: Colors.white),
                ),
                Text(
                  "clear_filter".tr,
                  style: context.textTheme.bodyMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp),
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
        body: IndexedStack(
          index: controller.showRelatedHousesView.value ? 1 : 0,
          children: [
            _body(context, isDarkMode),
            RealtedHousesView(
              propertyIds: controller.relatedHouseIds.toList(),
              onBack: () => controller.showRelatedHousesView.value = false,
              isVisible: controller.showRelatedHousesView.value,
            ),
          ],
        ),
      );
    });
  }
}

// Custom painter for location pin shape
class LocationPinPainter extends CustomPainter {
  final Color color;

  LocationPinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double width = size.width;
    final double height = size.height;
    final double circleRadius = width * 0.35;
    final double centerX = width / 2;
    final double centerY = circleRadius + 3;

    // Draw the top circle part
    canvas.drawCircle(
      Offset(centerX, centerY),
      circleRadius,
      paint,
    );

    // Draw the bottom pointed triangle
    final path = ui.Path();
    final bottomPointY = height - 2;
    final sideWidth = circleRadius * 0.45;

    // Triangle starts slightly inside the circle to blend smoothly
    path.moveTo(centerX - sideWidth, centerY + circleRadius * 0.85);
    path.lineTo(centerX, bottomPointY);
    path.lineTo(centerX + sideWidth, centerY + circleRadius * 0.85);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LocationPinPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
