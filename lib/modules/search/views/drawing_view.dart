import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
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
    // Controller'ı `initialCenter` ile başlatıyoruz
    _drawingController =
        Get.put(DrawingController(initialCenter: widget.initialCenter));
    _drawingController.mapController = _mapController;
  }

  LatLng? convertPositionToLatLng(Offset position) {
    final point = Point<double>(position.dx, position.dy);
    return _mapController.camera.pointToLatLng(point);
  }

  // AppBar başlığını Rusça dilbilgisine uygun hale getiren yardımcı fonksiyon
  String _getAreaTitle(int count) {
    if (count == 0) {
      return "Рисование области"; // "Alan Çizimi"
    }
    // Rusça'da sayıya göre kelime sonu değişir (1 область, 2 области, 5 областей)
    if (count % 10 == 1 && count % 100 != 11) {
      return "$count область";
    }
    if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return "$count области";
    }
    return "$count областей";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- TASARIMA UYGUN YENİ APPBAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black, // Geri butonu rengi için
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        // Çizilen alan sayısına göre dinamik olarak değişen başlık
        title: Obx(() => Text(
              _getAreaTitle(_drawingController.completedPolygons.length),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            )),
        centerTitle: true,
        actions: [
          // "Сбросить" (Sıfırla) butonu
          Obx(() {
            // Sadece en az bir çizim varsa göster
            if (_drawingController.completedPolygons.isNotEmpty) {
              return TextButton(
                onPressed: _drawingController.resetDrawings,
                child: Text(
                  "Сбросить",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              );
            }
            return SizedBox.shrink(); // Hiç çizim yoksa boşluk göster
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
            // onTap event'ini kaldırdık çünkü GestureDetector harita etkileşimini engelliyor.
            // Harita etkileşimini MapOptions'tan yöneteceğiz.
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialCenter,
                initialZoom: 12,
                // Çizim yaparken haritayı iki parmakla kaydırmaya izin ver
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.pinchMove | InteractiveFlag.pinchZoom,
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

          // --- TASARIMA UYGUN YENİ ALT KONTROL BUTONLARI ---
          // Obx widget'ı ile butonları sadece çizim yapıldıktan sonra gösteriyoruz
          Obx(() {
            if (_drawingController.completedPolygons.isEmpty) {
              return SizedBox.shrink(); // Hiç çizim yoksa hiçbir şey gösterme
            }
            // En az bir çizim varsa butonları göster
            return Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  // "Нарисовать ещё" (Daha fazla çiz) butonu
                  ElevatedButton.icon(
                    onPressed: () {
                      // Bu butonun özel bir işlevi yok, kullanıcı zaten çizmeye devam edebilir.
                      // Sadece görsel bir element.
                    },
                    icon: Icon(Icons.edit_outlined),
                    label: Text("Нарисовать ещё"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: StadiumBorder(), // Oval (kapsül) şekli
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 16),
                  // "Показать объявления" (İlanları Göster) butonu
                  ElevatedButton(
                    onPressed: _drawingController.finishDrawing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      foregroundColor: Colors.black,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Показать результаты", // "Sonuçları Göster"
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
