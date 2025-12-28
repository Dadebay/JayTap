import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/service/property_service.dart';
import 'package:jaytap/modules/search/views/drawing_view.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:jaytap/modules/search/controllers/realted_houses_controller.dart';
import 'package:jaytap/modules/search/models/ad_banner_model.dart';
import 'package:jaytap/modules/search/services/ad_banner_service.dart';

class SearchControllerMine extends GetxController {
  final mapController = MapController();
  final PropertyService _propertyService = PropertyService();
  final AdBannerService _adBannerService = AdBannerService();
  final userLocation = Rxn<LatLng>();
  RxBool isLoadingLocation = false.obs;
  Rx<LatLng> currentPosition = LatLng(37.9601, 58.3261).obs;
  RxDouble currentZoom = 12.0.obs;
  RxList<MapPropertyModel> properties = <MapPropertyModel>[].obs;
  RxList<MapPropertyModel> filteredProperties = <MapPropertyModel>[].obs;
  RxList<AdBannerModel> adBanners = <AdBannerModel>[].obs;
  final homeController = Get.find<HomeController>();
  RxBool isDrawingMode = false.obs;
  RxList<LatLng> drawingPoints = <LatLng>[].obs;
  RxList<Offset> drawingOffsets = <Offset>[].obs;
  RxList<Polygon> polygons = <Polygon>[].obs;
  RxList<Polyline> polylines = <Polyline>[].obs;
  final refreshMask = 0.obs;
  RxBool isLoading = false.obs;
  RxDouble mapRotation = 0.0.obs;
  RxDouble scale = 1.0.obs;
  final List<int>? initialPropertyIds;
  double _initialRotation = 0.0;
  RxInt propertiesInPolygonCount = 0.obs;
  RxBool showRelatedHousesView = false.obs;
  RxList<int> relatedHouseIds = <int>[].obs;
  RxBool shouldCenterMap = false.obs;

  SearchControllerMine({this.initialPropertyIds});

  @override
  void onInit() {
    super.onInit();
    fetchAdBanners();
    if (initialPropertyIds != null && initialPropertyIds!.isNotEmpty) {
      fetchPropertiesByIds(initialPropertyIds!, fitBounds: true);
    } else {
      fetchProperties(fitBounds: true);
    }
    ever(isLoading, (loading) {
      // Yükleme bittiğinde ve harita hazır olduğunda işlem yap
      // if (!loading) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     if (userLocation.value != null) {
      //       mapController.move(userLocation.value!, currentZoom.value);
      //     } else {
      //       _fitMapToMarkers();
      //     }
      //   });
      // }
    });
  }

  Future<void> goToDrawingPage() async {
    final result = await Get.to<List<Polygon>>(() => DrawingView(initialCenter: mapController.camera.center));
    if (result != null) {
      polygons.value = result;
      filterPropertiesByPolygons();
    }
  }

  void filterPropertiesByPolygons() {
    if (polygons.isEmpty) return;

    final propertiesInPolygon = properties.where((property) {
      final point = LatLng(property.lat!, property.long!);
      for (final polygon in polygons) {
        if (isPointInPolygon(point, polygon.points)) return true;
      }
      return false;
    }).toList();

    filteredProperties.value = propertiesInPolygon;
    propertiesInPolygonCount.value = filteredProperties.length;

    print("--- Filtered Properties inside drawn polygon (from DrawingView): ---");
    if (filteredProperties.isEmpty) {
      print("No properties found inside the drawn area.");
    } else {
      for (var property in filteredProperties) {
        print("Property ID: ${property.id}, Price: ${property.price}, Lat: ${property.lat}, Long: ${property.long}");
      }
    }
    print("--------------------------------------------------------------------");
  }

  Future<void> fetchPropertiesByIds(List<int> ids, {bool fitBounds = false}) async {
    print("--- Fetching properties by IDs: $ids");
    isLoading.value = true;
    filteredProperties.clear();
    try {
      final fetchedProperties = await _propertyService.fetchPropertiesByIds(propertyIds: ids);
      final List<MapPropertyModel> mapProperties = fetchedProperties.map((p) {
        final prop = p as PropertyModel;
        return MapPropertyModel(
          id: prop.id,
          lat: prop.lat,
          long: prop.long,
          price: prop.price,
          category: prop.category?.name,
          subcat: null,
        );
      }).toList();
      filteredProperties.assignAll(mapProperties);
      properties.assignAll(mapProperties); // ✅ Update master list too
      
      // ✅ Initial sync to ensure RelatedHousesView gets correct IDs immediately
      syncRelatedHouses();

      if (fitBounds) {
        _fitMapToMarkers();
      }
      print("--- filteredProperties list now has ${filteredProperties.length} items.");
    } catch (e) {
      print("Hata fetchPropertiesByIds: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setFilterData({List<int>? propertyIds, List<dynamic>? polygonCoordinates}) async {
    await fetchProperties();
    List<MapPropertyModel> currentPropertiesToFilter = List.from(properties);

    if (propertyIds != null) {
      currentPropertiesToFilter = currentPropertiesToFilter.where((p) => propertyIds.contains(p.id)).toList();
    }

    if (polygonCoordinates != null && polygonCoordinates.isNotEmpty) {
      clearDrawing();
      drawSavedPolygon(polygonCoordinates);
    } else {
      print("SearchControllerMine: setFilterData - No new saved polygon. Checking for existing manual drawing.");
      if (polygons.isNotEmpty) {
        // Mevcut poligonları koru
      } else {
        clearDrawing();
      }
    }

    if (drawingPoints.isNotEmpty) {
      print("SearchControllerMine: setFilterData - Applying spatial filter based on drawingPoints.");
      final List<MapPropertyModel> spatiallyFilteredList = [];
      for (var property in currentPropertiesToFilter) {
        if (property.long != null && property.lat != null) {
          final point = LatLng(property.lat!, property.long!);
          if (isPointInPolygon(point, drawingPoints)) {
            spatiallyFilteredList.add(property);
          }
        }
      }
      filteredProperties.assignAll(spatiallyFilteredList);
    } else {
      filteredProperties.assignAll(currentPropertiesToFilter);
      print("SearchControllerMine: setFilterData - No spatial filter applied. Assigning current properties.");
    }

    // ✅ Filter değiştiğinde related houses'ı senkronize et
    syncRelatedHouses();
  }

  Future<void> findAndMoveToCurrentUserLocation() async {
    isLoadingLocation.value = true;
    await _determinePositionAndMove();
    if (userLocation.value != null) {
      shouldCenterMap.value = true;
    }
    isLoadingLocation.value = false;
  }

  Future<bool> _handleLocationPermission() async {
    print("Konum izni kontrol ediliyor...");
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("GPS servisi durumu: $serviceEnabled");
    if (!serviceEnabled) {
      print("GPS kapalı. Servis durumu: $serviceEnabled");
      Get.dialog(
        AlertDialog(
          title: Text('gps_disabled_title'.tr),
          content: Text('gps_disabled_content'.tr),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'.tr),
              onPressed: () => Get.back(),
            ),
            TextButton(
              child: Text('settings'.tr),
              onPressed: () {
                Geolocator.openLocationSettings();
                Get.back();
              },
            ),
          ],
        ),
      );
      return false;
    }

    var status = await Permission.locationWhenInUse.status;
    print("İzin durumu: $status");
    if (status.isDenied) {
      print("Konum izni reddedildi, izin isteniyor...");
      status = await Permission.locationWhenInUse.request();
      print("İzin isteği sonucu: $status");
      if (status.isDenied) {
        print("İzin reddedildi. Durum: $status");
        Get.snackbar('permission_denied_title'.tr, 'permission_denied_content'.tr);
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
      print("İzin kalıcı olarak reddedildi. Durum: $status");
      Get.snackbar(
        'permission_permanently_denied_title'.tr,
        'permission_permanently_denied_content'.tr,
        mainButton: TextButton(
          onPressed: () => openAppSettings(),
          child: Text('settings'.tr),
        ),
      );
      return false;
    }

    print("Konum izni alındı. Durum: $status");
    return true;
  }

// search_controller_mine.dart

  Future<void> _determinePositionAndMove() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    Position? position;
    try {
      print("Cihazın ağ durumu kontrol ediliyor...");
      // connectivity_plus v5 ve sonrası liste döndürür, bu yüzden .contains kullanılır.
      final connectivityResult = await (Connectivity().checkConnectivity());
      bool isConnected = connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi);
      print("Ağ bağlantısı durumu (connectivity_plus): $isConnected, Durum: $connectivityResult");

      print("Yüksek doğrulukla konum alınıyor... (10 saniye zaman aşımı ile)");
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // <-- ZAMAN AŞIMI EKLENDİ
      );
    } catch (e) {
      print("Yüksek doğruluk hatası veya zaman aşımı: $e");
      try {
        print("Düşük doğrulukla konum alınıyor... (15 saniye zaman aşımı ile)");
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
          timeLimit: const Duration(seconds: 15), // <-- ZAMAN AŞIMI EKLENDİ
        );
      } catch (e) {
        print("Düşük doğruluk hatası veya zaman aşımı: $e");
        // Get.snackbar('Hata',
        //     'Konum alınamadı. GPS sinyalini ve internet bağlantınızı kontrol edin.');
        return;
      }
    }

    if (position != null) {
      final newLocation = LatLng(position.latitude, position.longitude);
      userLocation.value = newLocation;
      currentPosition.value = newLocation;
      print("Konum bulundu: Lat=${position.latitude}, Long=${position.longitude}, Doğruluk: ${position.accuracy}");
      shouldCenterMap.value = true;
    }
  }

  Future<void> fetchProperties({int? categoryId, bool fitBounds = false}) async {
    try {
      isLoading.value = true;
      properties.clear();
      filteredProperties.clear();

      List<MapPropertyModel> fetchedProperties;
      if (categoryId != null) {
        fetchedProperties = await _propertyService.getPropertiesByCategory(categoryId);
        print("Fetched properties by category: $fetchedProperties");
      } else {
        fetchedProperties = await _propertyService.getAllProperties();
      }
      properties.assignAll(fetchedProperties);
      _createMarkersFromApiData();
      if (fitBounds) {
        _fitMapToMarkers();
      }
    } catch (e) {
      print("Hata fetchProperties: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _createMarkersFromApiData() {
    filteredProperties.assignAll(properties);
  }

  Future<void> fetchTajircilik() async {
    isLoading.value = true;
    properties.clear();
    filteredProperties.clear();
    try {
      List<MapPropertyModel> fetchedProperties = await _propertyService.getTajircilikHouses();
      properties.assignAll(fetchedProperties);
      filteredProperties.assignAll(properties);
    } catch (e) {
      print("Hata fetchTajircilik: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchJayByID({required int categoryID}) async {
    isLoading.value = true;
    properties.clear();
    filteredProperties.clear();
    try {
      List<MapPropertyModel> fetchedProperties = await _propertyService.fetchJayByID(categoryID: categoryID);
      properties.assignAll(fetchedProperties);
      filteredProperties.assignAll(properties);
    } catch (e) {
      print("Hata fetchJayByID: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _fitMapToMarkers() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (!mapController.ready) return; // <-- BU SATIRI SİLİN
      final validProperties = filteredProperties.where((p) => p.lat != null && p.long != null).toList();
      if (validProperties.length > 1) {
        mapController.fitCamera(
          CameraFit.coordinates(
            coordinates: validProperties.map((p) => LatLng(p.lat!, p.long!)).toList(),
            padding: EdgeInsets.all(50),
          ),
        );
      } else if (validProperties.length == 1) {
        final prop = validProperties.first;
        mapController.move(LatLng(prop.lat!, prop.long!), 15.0);
      }
    });
  }

  void toggleDrawingMode() {
    isDrawingMode.value = !isDrawingMode.value;
    if (!isDrawingMode.value) {
      if (drawingPoints.isNotEmpty) {
        manuallyFinishDrawing();
      }
    } else {
      polygons.clear();
      polylines.clear();
      drawingPoints.clear();
      drawingOffsets.clear();
    }
  }

  void clearDrawing() {
    print("SearchControllerMine: clearDrawing called.");
    drawingPoints.clear();
    drawingOffsets.clear();
    polygons.clear();
    polylines.clear();
    propertiesInPolygonCount.value = 0;
  }

  void onPanStart(DragStartDetails details) {
    if (!isDrawingMode.value) return;

    filteredProperties.clear();
    polygons.clear();
    polylines.clear();
    drawingPoints.clear();
    drawingOffsets.clear();
    propertiesInPolygonCount.value = 0;
    drawingOffsets.add(details.localPosition);
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (!isDrawingMode.value || drawingOffsets.isEmpty) return;

    const minDistance = 2.0;
    final lastPoint = drawingOffsets.last;
    final newPoint = details.localPosition;
    final distance = (newPoint - lastPoint).distance;

    if (distance > minDistance) {
      drawingOffsets.add(newPoint);
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (!isDrawingMode.value) return;
    manuallyFinishDrawing();
  }

  void onScaleStart(ScaleStartDetails details) {
    _initialRotation = mapRotation.value;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    final newRotationRad = _initialRotation + details.rotation;
    mapRotation.value = newRotationRad;

    final newRotationDeg = newRotationRad * 180 / pi;
    try {
      mapController.rotate(newRotationDeg);
    } catch (e) {
      print("Map rotate hatası: $e");
    }
  }

  void manuallyFinishDrawing() {
    polygons.clear();
    polylines.clear();

    if (drawingOffsets.length < 3) {
      clearDrawing();
      isDrawingMode.value = false;
      return;
    }

    drawingPoints.clear();
    for (var offset in drawingOffsets) {
      final latlng = mapController.camera.pointToLatLng(Point(offset.dx.toDouble(), offset.dy.toDouble()));
      drawingPoints.add(latlng);
    }

    isDrawingMode.value = false;

    if (drawingPoints.length < 3) {
      clearDrawing();
      return;
    }

    if (drawingPoints.first != drawingPoints.last) {
      drawingPoints.add(drawingPoints.first); // Path'i kapat
    }

    _filterAndCreateSimpleMarkers();
    _createMaskAndBorder();
    drawingOffsets.clear();
    propertiesInPolygonCount.value = filteredProperties.length;
  }

  void _filterAndCreateSimpleMarkers() {
    final newFilteredList = <MapPropertyModel>[];
    for (var property in properties) {
      if (property.long != null && property.lat != null) {
        final point = LatLng(property.lat!, property.long!);
        if (isPointInPolygon(point, drawingPoints)) {
          newFilteredList.add(property);
        }
      }
    }
    filteredProperties.assignAll(newFilteredList);
    print("--- Filtered Properties inside drawn polygon: ---");
    if (filteredProperties.isEmpty) {
      print("No properties found inside the drawn area.");
    } else {
      for (var property in filteredProperties) {
        print("Property ID: ${property.id}, Price: ${property.price}, Lat: ${property.lat}, Long: ${property.long}");
      }
    }
    print("-------------------------------------------------");
  }

  void _createMaskAndBorder() {
    polygons.clear();
    final bounds = mapController.camera.visibleBounds;
    final outerPoints = [
      bounds.northWest,
      bounds.southWest,
      bounds.southEast,
      bounds.northEast,
    ];
    polygons.add(Polygon(
      points: outerPoints,
      holePointsList: [drawingPoints],
      color: Colors.grey.withOpacity(0.4),
      borderColor: Colors.blue,
      borderStrokeWidth: 4,
    ));
  }

  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;
    int intersectCount = 0;
    for (int j = 0; j < polygon.length; j++) {
      final vertA = polygon[j];
      final vertB = polygon[(j + 1) % polygon.length];
      if (_rayCastIntersect(point, vertA, vertB)) intersectCount++;
    }
    return (intersectCount % 2) == 1;
  }

  bool _rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = point.latitude;
    double pX = point.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false;
    }

    if ((aY <= pY && bY > pY) || (aY > pY && bY <= pY)) {
      double vt = (pY - aY) / (bY - aY);
      if (pX < aX + vt * (bX - aX)) return true;
    }
    return false;
  }

  void drawSavedPolygon(List<dynamic> coordinates) {
    if (coordinates.isEmpty) return;

    try {
      polygons.clear();
      polylines.clear();
      drawingPoints.clear();

      List<LatLng> currentPolygonPoints = [];
      for (var i = 0; i < coordinates.length; i++) {
        final coord = coordinates[i];
        final lat = double.parse(coord['lat'].toString());
        final long = double.parse(coord['long'].toString());

        if (lat == 0.0 && long == 0.0) {
          if (currentPolygonPoints.length >= 3) {
            polygons.add(Polygon(
              points: List.from(currentPolygonPoints),
              color: Colors.transparent,
              borderStrokeWidth: 1.0,
              borderColor: Colors.blue,
              isFilled: true,
            ));
            drawingPoints.addAll(currentPolygonPoints);
          }
          currentPolygonPoints.clear();
        } else {
          currentPolygonPoints.add(LatLng(lat, long));
        }
      }

      if (currentPolygonPoints.length >= 3) {
        polygons.add(Polygon(
          points: List.from(currentPolygonPoints),
          color: Colors.transparent,
          borderStrokeWidth: 1.0,
          borderColor: Colors.blue,
          isFilled: true,
        ));
        drawingPoints.addAll(currentPolygonPoints);
      }

      if (polygons.isNotEmpty) {
        filterPropertiesByPolygons();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final allPoints = polygons.expand((p) => p.points).toList();
          if (allPoints.isNotEmpty) {
            mapController.fitCamera(
              CameraFit.coordinates(
                coordinates: allPoints,
                padding: EdgeInsets.all(50),
              ),
            );
          }
        });
      }
    } catch (e) {
      print("Hata drawSavedPolygon: $e");
    }
  }

  Future<void> searchByAddress(String address) async {
    if (address.isEmpty) {
      filteredProperties.assignAll(properties);
      return;
    }
    isLoading.value = true;
    try {
      final fetchedProperties = await _propertyService.searchPropertiesByAddress(address);
      filteredProperties.assignAll(fetchedProperties);
      _fitMapToMarkers();
    } catch (e) {
      print("Hata searchByAddress: $e");
    } finally {
      isLoading.value = false;
    }
  }

  bool get hasActiveMapFilter {
    return polygons.isNotEmpty || drawingPoints.isNotEmpty;
  }

  void updateRelatedHouses() {
    final List<int> currentIds = filteredProperties.map((property) => property.id).toList();
    relatedHouseIds.assignAll(currentIds);
    showRelatedHousesView.value = true;

    if (Get.isRegistered<RealtedHousesController>(tag: 'related_houses_controller')) {
      final controller = Get.find<RealtedHousesController>(tag: 'related_houses_controller');
      controller.checkGlobalFilterState();
    }
  }

  void syncRelatedHouses() {
    final List<int> currentIds = filteredProperties.map((property) => property.id).toList();
    relatedHouseIds.assignAll(currentIds);

    if (Get.isRegistered<RealtedHousesController>(tag: 'related_houses_controller')) {
      final controller = Get.find<RealtedHousesController>(tag: 'related_houses_controller');
      // ✅ Sadece resetlemek yerine global durumu kontrol et
      controller.checkGlobalFilterState();
    }
  }

  Future<void> fetchAdBanners() async {
    try {
      final banners = await _adBannerService.fetchAdBanners();
      adBanners.assignAll(banners);
      print('Fetched ${banners.length} ad banners');
    } catch (e) {
      print('Error fetching ad banners: $e');
    }
  }

  void showAdBannerDetail(AdBannerModel banner) {
    Get.bottomSheet(
      _buildBannerBottomSheet(banner),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildBannerBottomSheet(AdBannerModel banner) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag indicator
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Banner Image
                if (banner.img.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage('https://jaytap.com.tm${banner.img}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                SizedBox(height: 16),
                // Title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    banner.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Description
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    banner.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
