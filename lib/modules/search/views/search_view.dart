import 'dart:ui' as ui;
import 'package:flutter_map/flutter_map.dart';
import 'package:jaytap/core/services/api_constants.dart';
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
                          },
                          interactionOptions: InteractionOptions(
                              flags: controller.isDrawingMode.value
                                  ? InteractiveFlag.none
                                  : InteractiveFlag.all),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: ApiConstants.mapUrl,
                            maxZoom: 18,
                            minZoom: 5,
                            userAgentPackageName: 'com.gurbanov.jaytap',
                          ),
                          Obx(() => PolylineLayer(
                              polylines: controller.polylines.toList())),
                          Obx(() => PolygonLayer(
                              polygons: controller.polygons.toList())),
                          Obx(() {
                            return MarkerLayer(
                              markers: controller.filteredProperties
                                  .where((property) =>
                                      property.lat != null &&
                                      property.long != null)
                                  .map((property) {
                                String title = property.category ??
                                    property.subcat ??
                                    'satlyk';
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
                              }).toList(),
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
                  if (controller.drawingOffsets.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return CustomPaint(
                    painter: DrawingPainter(controller.drawingOffsets.toList()),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints.expand(),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
        Positioned(
          top: 15.0,
          left: 15,
          right: 15,
          child: SearchAppBar(controller: controller),
        ),
        Positioned(
          bottom: 15.0,
          left: 15,
          child: ElevatedButton(
              onPressed: () {
                final List<int> currentIds = controller.filteredProperties
                    .map((property) => property.id)
                    .toList();
                Get.to(() => RealtedHousesView(propertyIds: currentIds));
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
                    child: Icon(Icons.list, color: Colors.grey),
                  ),
                  Text(
                    "relatedHouses".tr,
                    style:
                        context.textTheme.bodyMedium!.copyWith(fontSize: 16.sp),
                  )
                ],
              )),
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
                    padding: const EdgeInsets.only(right: 4, bottom: 4),
                    child: Icon(IconlyLight.delete, color: Colors.grey),
                  ),
                  Text(
                    "clear_filter".tr,
                    style:
                        context.textTheme.bodyMedium!.copyWith(fontSize: 16.sp),
                  )
                ],
              )),
        ),
        MapDrawingControls(controller: controller),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _body(context, isDarkMode),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = ui.Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
