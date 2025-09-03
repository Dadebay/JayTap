import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/modules/search/controllers/drawing_controller.dart';
import 'package:latlong2/latlong.dart';

class DrawingView extends StatefulWidget {
  final LatLng initialCenter;
  const DrawingView({super.key, required this.initialCenter});

  @override
  State<DrawingView> createState() => _DrawingViewState();
}

class _DrawingViewState extends State<DrawingView> {
  final _mapController = MapController();
  late final DrawingController _drawingController;

  @override
  void initState() {
    super.initState();

    _drawingController =
        Get.put(DrawingController(initialCenter: widget.initialCenter));
    _drawingController.mapController = _mapController;
  }

  LatLng? convertPositionToLatLng(Offset position) {
    final point = Point<double>(position.dx, position.dy);
    return _mapController.camera.pointToLatLng(point);
  }

  String _getAreaTitle(int count) {
    if (count == 0) {
      return 'drawing_area'.tr;
    }

    if (count % 10 == 1 && count % 100 != 11) {
      return "$count ${'area'.tr}";
    }
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return "$count ${'areas'.tr}";
    }
    return "$count ${'of_areas'.tr}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
              _getAreaTitle(_drawingController.completedPolygons.length),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            )),
        centerTitle: true,
        actions: [
          Obx(() {
            if (_drawingController.completedPolygons.isNotEmpty) {
              return TextButton(
                onPressed: _drawingController.resetDrawings,
                child: Text(
                  'reset'.tr,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) {
              final point = convertPositionToLatLng(details.localPosition);
              if (point != null) _drawingController.onPanStart(point);
            },
            onPanUpdate: (details) {
              final point = convertPositionToLatLng(details.localPosition);
              if (point != null) _drawingController.onPanUpdate(point);
            },
            onPanEnd: (_) => _drawingController.onPanEnd(),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: 12,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.pinchMove | InteractiveFlag.pinchZoom,
                ),
              ),
              children: [
                TileLayer(
                  maxZoom: 18,
                  minZoom: 5,
                  urlTemplate: ApiConstants.mapUrl,
                  userAgentPackageName: 'com.gurbanov.jaytap',
                ),
                Obx(() => PolygonLayer(
                    polygons: _drawingController.completedPolygons.toList())),
                Obx(() {
                  if (_drawingController.currentDrawingLine.value != null) {
                    return PolylineLayer(polylines: [
                      _drawingController.currentDrawingLine.value!
                    ]);
                  }
                  return SizedBox.shrink();
                }),
              ],
            ),
          ),
          Obx(() {
            if (_drawingController.completedPolygons.isEmpty) {
              return SizedBox.shrink();
            }

            return Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  // ElevatedButton.icon(
                  //   onPressed: () {},
                  //   icon: Icon(Icons.edit_outlined),
                  //   label: Text('draw_more'.tr),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Theme.of(context).colorScheme.surface,
                  //     foregroundColor: Theme.of(context).colorScheme.onSurface,
                  //     shape: StadiumBorder(),
                  //     padding:
                  //         EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  //   ),
                  // ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _drawingController.finishDrawing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'show_results'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
