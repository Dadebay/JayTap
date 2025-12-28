import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/modules/search/controllers/drawing_controller.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;

class DrawingView extends StatefulWidget {
  final LatLng initialCenter;
  const DrawingView({super.key, required this.initialCenter});

  @override
  State<DrawingView> createState() => _DrawingViewState();
}

class _DrawingViewState extends State<DrawingView> {
  final _mapController = MapController();
  late final DrawingController _drawingController;
  bool _isDrawing = false;
  int _pointerCount = 0;
  bool _drawingModeActive = false;

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
    if (count == 0) return 'drawing_area'.tr;

    if (count % 10 == 1 && count % 100 != 11) return "$count ${'area'.tr}";
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return "$count ${'areas'.tr}";
    }
    return "$count ${'of_areas'.tr}";
  }

  void _toggleDrawingMode() {
    setState(() {
      _drawingModeActive = !_drawingModeActive;
    });
  }

  // Button textini belirle
  String _getDrawButtonText() {
    if (_drawingModeActive) {
      return 'drawing_active'.tr; // "Çyzgy başlady" translation keyiniz
    } else if (_drawingController.completedPolygons.isEmpty) {
      return 'start_drawing'.tr; // "Başlamak" veya "Начать рисовать"
    } else {
      return 'draw_more'.tr; // "Ýene çyz" veya "Ещё рисовать"
    }
  }

  LatLng _calculatePolygonCenter(List<LatLng> points) {
    if (points.isEmpty) return LatLng(0, 0);

    double latSum = 0;
    double lngSum = 0;
    int count = points.length;

    if (points.first == points.last && count > 1) {
      count--;
    }

    for (int i = 0; i < count; i++) {
      latSum += points[i].latitude;
      lngSum += points[i].longitude;
    }

    return LatLng(latSum / count, lngSum / count);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 1,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop()),
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
                  onPressed: () {
                    _drawingController.resetDrawings();
                    setState(() {
                      _drawingModeActive = false;
                    });
                  },
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
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: 12,
                interactionOptions: InteractionOptions(
                  flags: _drawingModeActive
                      ? InteractiveFlag.none
                      : (InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom |
                          InteractiveFlag.drag),
                ),
              ),
              children: [
                TileLayer(
                  maxZoom: 18,
                  minZoom: 5,
                  keepBuffer: 8,
                  panBuffer: 2,
                  urlTemplate: ApiConstants.mapUrl,
                  userAgentPackageName: 'com.gurbanov.jaytap',
                ),
                Obx(() {
                  if (_drawingController.completedPolygons.isNotEmpty) {
                    return CustomPaint(
                      painter: MapMaskPainter(
                        _drawingController.completedPolygons.toList(),
                        _mapController,
                      ),
                      child: Container(color: Colors.transparent),
                    );
                  }
                  return SizedBox.shrink();
                }),
                Obx(() => PolygonLayer(
                    polygons: _drawingController.completedPolygons.toList())),
                // X işareti markerları
                Obx(() => MarkerLayer(
                      markers: _drawingController.completedPolygons
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        Polygon polygon = entry.value;

                        LatLng center = _calculatePolygonCenter(polygon.points);

                        return Marker(
                          point: center,
                          width: 25,
                          height: 25,
                          child: GestureDetector(
                            onTap: () {
                              _drawingController.removePolygon(index);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )),
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
            if (_drawingModeActive)
              Positioned.fill(
                child: Listener(
                  onPointerDown: (event) {
                    _pointerCount++;

                    if (_pointerCount == 1 &&
                        event.kind == PointerDeviceKind.touch) {
                      setState(() => _isDrawing = true);
                      final point =
                          convertPositionToLatLng(event.localPosition);
                      if (point != null) _drawingController.onPanStart(point);
                    } else if (_pointerCount > 1) {
                      if (_isDrawing) {
                        setState(() => _isDrawing = false);
                        _drawingController.onPanEnd();
                      }
                    }
                  },
                  onPointerMove: (event) {
                    if (_isDrawing && _pointerCount == 1) {
                      final point =
                          convertPositionToLatLng(event.localPosition);
                      if (point != null) _drawingController.onPanUpdate(point);
                    }
                  },
                  onPointerUp: (event) {
                    _pointerCount--;
                    if (_pointerCount < 0) _pointerCount = 0;

                    if (_isDrawing && _pointerCount == 0) {
                      setState(() {
                        _isDrawing = false;
                        _drawingModeActive = false;
                      });
                      _drawingController.onPanEnd();
                    }
                  },
                  onPointerCancel: (event) {
                    _pointerCount--;
                    if (_pointerCount < 0) _pointerCount = 0;

                    if (_isDrawing) {
                      setState(() {
                        _isDrawing = false;
                        _drawingModeActive = false;
                      });
                      _drawingController.onPanEnd();
                    }
                  },
                  behavior: HitTestBehavior.translucent,
                  child: Container(color: Colors.transparent),
                ),
              ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 40, right: 40),
                    child: ElevatedButton(
                      onPressed: _toggleDrawingMode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _drawingModeActive
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        foregroundColor:
                            _drawingModeActive ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: _drawingModeActive ? 8 : 2,
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            IconConstants.selectionIcon,
                            color: _drawingModeActive
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            width: 24,
                            height: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            _getDrawButtonText(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Obx(() {
                    if (_drawingController.completedPolygons.isEmpty) {
                      return SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _drawingController.finishDrawing(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
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
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapMaskPainter extends CustomPainter {
  final List<Polygon> polygons;
  final MapController mapController;

  MapMaskPainter(this.polygons, this.mapController);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.45)
      ..style = PaintingStyle.fill;

    canvas.saveLayer(Offset.zero & size, Paint());

    canvas.drawRect(Offset.zero & size, paint);

    for (final polygon in polygons) {
      if (polygon.points.isEmpty) continue;
      final path = ui.Path();
      final first =
          mapController.camera.latLngToScreenPoint(polygon.points.first);
      path.moveTo(first.x.toDouble(), first.y.toDouble());

      for (int i = 1; i < polygon.points.length; i++) {
        final p = mapController.camera.latLngToScreenPoint(polygon.points[i]);
        path.lineTo(p.x.toDouble(), p.y.toDouble());
      }
      path.close();

      canvas.drawPath(path, Paint()..blendMode = BlendMode.clear);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return (oldDelegate as MapMaskPainter).polygons != polygons;
  }
}
