import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/service/property_service.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:latlong2/latlong.dart';

class SearchControllerMine extends GetxController {
  MapController mapController = MapController();
  final PropertyService _propertyService = PropertyService();
  final Rx<LatLng?> userLocation = Rx(null);
  RxBool isLoadingLocation = false.obs;
  Rx<LatLng> currentPosition = LatLng(37.95, 58.38).obs;
  RxDouble currentZoom = 12.0.obs;
  RxList<MapPropertyModel> properties = <MapPropertyModel>[].obs;
  RxList<MapPropertyModel> filteredProperties = <MapPropertyModel>[].obs;
  final homeController = Get.find<HomeController>();
  RxBool isDrawingMode = false.obs;
  RxList<LatLng> drawingPoints = <LatLng>[].obs;
  RxList<Polygon> polygons = <Polygon>[].obs;
  RxList<Polyline> polylines = <Polyline>[].obs;

  RxBool isLoading = false.obs;
  bool isMapReady = false;

  final List<int>? initialPropertyIds;

  SearchControllerMine({this.initialPropertyIds});

  @override
  void onInit() {
    super.onInit();
    if (initialPropertyIds != null && initialPropertyIds!.isNotEmpty) {
      fetchPropertiesByIds(initialPropertyIds!);
    } else {
      fetchProperties();
    }

    _determinePositionAndMove(moveToPosition: false);
  }

  Future<void> fetchPropertiesByIds(List<int> ids) async {
    print("--- Fetching properties by IDs: $ids");
    isLoading.value = true;
    properties.clear();
    filteredProperties.clear();
    try {
      final fetchedProperties =
          await _propertyService.fetchPropertiesByIds(propertyIds: ids);

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

      properties.assignAll(mapProperties);
      filteredProperties.assignAll(properties);
      print("--- properties list now has ${properties.length} items.");
      print(
          "--- filteredProperties list now has ${filteredProperties.length} items.");
      _fitMapToMarkers();
    } catch (e) {
      print(e);
      CustomWidgets.showSnackBar(
          'Error', 'Failed to load properties by IDs: $e', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  void loadPropertiesByIds(List<int> ids) {
    fetchPropertiesByIds(ids);
  }

  Future<void> findAndMoveToCurrentUserLocation() async {
    if (isLoadingLocation.value) return;

    try {
      isLoadingLocation.value = true;
      await _determinePositionAndMove(moveToPosition: true);
    } catch (e) {
      CustomWidgets.showSnackBar(
          'Hata', 'Konum bulunurken bir hata oluştu.', Colors.red);
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> _determinePositionAndMove({required bool moveToPosition}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      CustomWidgets.showSnackBar(
          'Error', 'Location services are disabled.', Colors.red);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        CustomWidgets.showSnackBar(
            'Error', 'Location permissions are denied', Colors.red);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      CustomWidgets.showSnackBar(
          'Error',
          'Location permissions are permanently denied, we cannot request permissions.',
          Colors.red);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20));
      userLocation.value = LatLng(position.latitude, position.longitude);
      if (moveToPosition && isMapReady) {
        mapController.move(userLocation.value!, 15.0);
      }
    } catch (e) {
      CustomWidgets.showSnackBar(
          'Error', 'Could not get current location.', Colors.red);
    }
  }

  Future<void> fetchProperties({int? categoryId}) async {
    try {
      print("--- Fetching properties for category: $categoryId");
      isLoading.value = true;
      properties.clear();
      filteredProperties.clear();

      List<MapPropertyModel> fetchedProperties;
      if (categoryId != null) {
        fetchedProperties =
            await _propertyService.getPropertiesByCategory(categoryId);
        print(fetchedProperties);
        if (fetchedProperties.isEmpty) {
          CustomWidgets.showSnackBar(
              'login_error', 'notFoundHouse.', Colors.red);
        }
      } else {
        fetchedProperties = await _propertyService.getAllProperties();
        print(
            "--- Got ${fetchedProperties.length} properties from getAllProperties");
      }
      properties.assignAll(fetchedProperties);
      print("--- properties list now has ${properties.length} items.");
      _createMarkersFromApiData();
    } catch (e) {
      CustomWidgets.showSnackBar('login_error', "noConnection2", Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  void _createMarkersFromApiData() {
    filteredProperties.assignAll(properties);
    _fitMapToMarkers();
  }

  Future<void> fetchTajircilik() async {
    isLoading.value = true;
    properties.clear();
    filteredProperties.clear();
    List<MapPropertyModel> fetchedProperties =
        await _propertyService.getTajircilikHouses();
    properties.assignAll(fetchedProperties);
    filteredProperties.assignAll(properties);
    isLoading.value = false;
  }

  Future<void> fetchJayByID({required int categoryID}) async {
    isLoading.value = true;
    properties.clear();
    filteredProperties.clear();
    List<MapPropertyModel> fetchedProperties =
        await _propertyService.fetchJayByID(categoryID: categoryID);
    properties.assignAll(fetchedProperties);
    filteredProperties.assignAll(properties);
    isLoading.value = false;
  }

  void onMapReady() {
    isMapReady = true;
    _fitMapToMarkers();
  }

  void _fitMapToMarkers() {
    if (!isMapReady) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final validProperties = filteredProperties
          .where((p) => p.lat != null && p.long != null)
          .toList();
      if (validProperties.length > 1) {
        mapController.fitCamera(
          CameraFit.coordinates(
            coordinates:
                validProperties.map((p) => LatLng(p.lat!, p.long!)).toList(),
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
      clearDrawing();
    } else {
      polygons.clear();
      polylines.clear();
      drawingPoints.clear();
    }
  }

  void clearDrawing() {
    drawingPoints.clear();
    polygons.clear();
    polylines.clear();
    filteredProperties.assignAll(properties);
  }

  void onPanStart(DragStartDetails details, LatLng point) {
    if (!isDrawingMode.value) return;

    filteredProperties.clear();
    polygons.clear();
    polylines.clear();
    drawingPoints.clear();
    drawingPoints.add(point);
  }

  void onPanUpdate(DragUpdateDetails details, LatLng point) {
    if (!isDrawingMode.value || drawingPoints.isEmpty) return;

    drawingPoints.add(point);
    _updateDrawingLine();
  }

  void onPanEnd(DragEndDetails details) {
    if (!isDrawingMode.value) return;
  }

  void _updateDrawingLine() {
    polylines.clear();
    polylines.add(
      Polyline(
        points: List.from(drawingPoints),
        color: Colors.blue,
        strokeWidth: 4,
      ),
    );
  }

  void manuallyFinishDrawing() {
    if (drawingPoints.length < 3) {
      clearDrawing();

      isDrawingMode.value = false;
      filteredProperties.assignAll(properties);
      return;
    }

    isDrawingMode.value = false;
    polylines.clear();

    if (drawingPoints.first != drawingPoints.last) {
      drawingPoints.add(drawingPoints.first);
    }

    _filterAndCreateSimpleMarkers();
    _createMaskAndBorder();
  }

  void _filterAndCreateSimpleMarkers() {
    final newFilteredList = <MapPropertyModel>[];
    for (var property in properties) {
      if (property.long != null && property.lat != null) {
        final point = LatLng(property.lat!, property.long!);
        if (_isPointInPolygon(point, drawingPoints)) {
          newFilteredList.add(property);
        }
      }
    }

    filteredProperties.assignAll(newFilteredList);
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
      color: Colors.grey.withOpacity(.4),
      // isFilled: true,
      borderColor: Colors.transparent,
    ));

    polygons.add(Polygon(
      points: List.from(drawingPoints),
      color: Colors.blue.withOpacity(.4),
      borderStrokeWidth: 4.0,
      borderColor: Colors.blue,
      // isFilled: false,
    ));
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if (_rayCastIntersect(point, polygon[j], polygon[j + 1])) {
        intersectCount++;
      }
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
      if (pX < aX + vt * (bX - aX)) {
        return true;
      }
    }
    return false;
  }
}
