import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class DrawingController extends GetxController {
  late MapController mapController;

  final Rx<Polyline?> currentDrawingLine = Rx(null);

  final RxList<LatLng> currentPoints = <LatLng>[].obs;

  final RxList<Polygon> completedPolygons = <Polygon>[].obs;

  final LatLng initialCenter = LatLng(37.95, 58.38);
  final double initialZoom = 6.0;

  void onPanStart(LatLng point) {
    currentPoints.clear();
    currentPoints.add(point);

    currentDrawingLine.value = Polyline(
      points: [point],
      strokeWidth: 35.0,
      color: Colors.blue.withOpacity(0.3),
      borderColor: Colors.blue.shade700,
      borderStrokeWidth: 2,
    );
  }

  void onPanUpdate(LatLng point) {
    currentPoints.add(point);
    currentDrawingLine.value = Polyline(
      points: List.from(currentPoints),
      borderColor: Colors.blue.shade700,
      borderStrokeWidth: 2,
      strokeWidth: 30.0,
      color: Colors.blue.withOpacity(0.3),
    );
  }

  void onPanEnd() {
    if (currentPoints.length > 2) {
      completedPolygons.add(Polygon(
        points: List.from(currentPoints),
        color: Colors.blue.withOpacity(0.3),
        borderColor: Colors.blue.shade700,
        borderStrokeWidth: 2,
        isFilled: true,
      ));
    }

    currentPoints.clear();
    currentDrawingLine.value = null;
  }

  void resetDrawings() {
    completedPolygons.clear();
    currentPoints.clear();
    currentDrawingLine.value = null;
  }

  void finishDrawing() {
    Get.back(result: completedPolygons.toList());
  }
}
