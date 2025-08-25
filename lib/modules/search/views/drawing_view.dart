import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/house_location_view.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bölge Çiz"),
        actions: [
          TextButton(
            onPressed: _drawingController.finishDrawing,
            child: Text("BİTİR"),
          )
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
            onTap: () {
              Get.to(() => HouseLocationView(
                  lat: _drawingController.initialCenter.latitude,
                  long: _drawingController.initialCenter.longitude));
            },
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: 12,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  maxZoom: 18,
                  minZoom: 5,
                  urlTemplate:
                      'http://216.250.10.237:8080/styles/test-style/{z}/{x}/{y}.png',
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
          // Alt Kontrol Butonları
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _drawingController.resetDrawings,
                  child: Text("Sıfırla"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
                ElevatedButton(
                  onPressed: _drawingController.finishDrawing,
                  child: Text("Çizimi Tamamla"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
