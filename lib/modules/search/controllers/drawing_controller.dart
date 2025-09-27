// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class DrawingController extends GetxController {
  late MapController mapController;

  final Rx<Polyline?> currentDrawingLine = Rx(null);

  final RxList<LatLng> currentPoints = <LatLng>[].obs;

  final RxList<Polygon> completedPolygons = <Polygon>[].obs;

  final LatLng initialCenter;
  final double initialZoom = 6.0;

  DateTime? _lastUpdate;

  DrawingController({required this.initialCenter});

  void onPanStart(LatLng point) {
    currentPoints.clear();
    currentPoints.add(point);

    currentDrawingLine.value = Polyline(
      points: [point],
      strokeWidth: 25.0,
      color: Colors.blue.withOpacity(0.3),
      borderColor: Colors.blue,
      borderStrokeWidth: 1,
    );
  }

  void onPanUpdate(LatLng point) {
    final now = DateTime.now();
    if (_lastUpdate != null &&
        now.difference(_lastUpdate!) < const Duration(milliseconds: 5)) {
      return;
    }
    _lastUpdate = now;
    currentPoints.add(point);
    currentDrawingLine.value = Polyline(
      points: List.unmodifiable(currentPoints),
      borderColor: Colors.blue.shade700,
      borderStrokeWidth: 2,
      strokeWidth: 25.0,
      color: Colors.blue.withOpacity(0.3),
    );
  }

  void onPanEnd() {
    if (currentPoints.length > 2) {
      final simplified = <LatLng>[currentPoints.first];
      for (var point in currentPoints.skip(1)) {
        if (Distance().as(LengthUnit.Meter, point, simplified.last) > 0.5) {
          simplified.add(point);
        }
      }
      if (simplified.length > 2) {
        if (simplified.first != simplified.last) {
          simplified.add(simplified.first);
        }
        completedPolygons.add(Polygon(
          points: simplified,
          color: Colors.transparent,
          borderColor: Colors.blue,
          borderStrokeWidth: 1,
          isFilled: true,
        ));
      }
    }

    currentPoints.clear();
    currentDrawingLine.value = null;
    _lastUpdate = null;
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
