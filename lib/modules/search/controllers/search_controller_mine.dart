import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/service/property_service.dart';
import 'package:jaytap/modules/search/views/drawing_view.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:latlong2/latlong.dart';

class SearchControllerMine extends GetxController {
  // MapController mapController = MapController();
  final mapController = MapController();
  final PropertyService _propertyService = PropertyService();
  final Rx<LatLng?> userLocation = Rx(null);
  RxBool isLoadingLocation = false.obs;
  Rx<LatLng> currentPosition = LatLng(37.9601, 58.3261).obs;
  RxDouble currentZoom = 12.0.obs;
  RxList<MapPropertyModel> properties = <MapPropertyModel>[].obs;
  RxList<MapPropertyModel> filteredProperties = <MapPropertyModel>[].obs;
  final homeController = Get.find<HomeController>();
  RxBool isDrawingMode = false.obs;
  RxList<LatLng> drawingPoints = <LatLng>[].obs;
  RxList<Offset> drawingOffsets = <Offset>[].obs;
  RxList<Polygon> polygons = <Polygon>[].obs;
  RxList<Polyline> polylines = <Polyline>[].obs;

  RxBool isLoading = false.obs;
  bool isMapReady = false;
  RxDouble mapRotation = 0.0.obs; // map rotate açısı
  RxDouble scale = 1.0.obs; // pinch için zoom
  final List<int>? initialPropertyIds;
  double _initialRotation = 0.0;
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

    ever(isLoading, (loading) {
      if (!loading && isMapReady) {
        if (userLocation.value != null) {
          mapController.move(userLocation.value!, currentZoom.value);
        } else {
          _fitMapToMarkers();
        }
      }
    });
  }

  Future<void> goToDrawingPage() async {
    final result = await Get.to<List<Polygon>>(
        () => DrawingView(initialCenter: mapController.camera.center));

    if (result != null) {
      polygons.value = result;
      filterPropertiesByPolygons();
    }
  }

  void filterPropertiesByPolygons() {
    if (polygons.isEmpty) {
      return;
    }

    final propertiesInPolygon = properties.where((property) {
      final point = LatLng(property.lat!, property.long!);

      for (final polygon in polygons) {
        if (isPointInPolygon(point, polygon.points)) {
          return true;
        }
      }
      return false;
    }).toList();

    filteredProperties.value = propertiesInPolygon;
  }

  Future<void> fetchPropertiesByIds(List<int> ids) async {
    print("--- Fetching properties by IDs: $ids");
    isLoading.value = true;
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

      filteredProperties.assignAll(mapProperties);
      print(
          "--- filteredProperties list now has ${filteredProperties.length} items.");
    } catch (e) {
      print(e);
      CustomWidgets.showSnackBar(
          'Error', 'Failed to load properties by IDs: $e', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  void setFilterData(
      {List<int>? propertyIds, List<dynamic>? polygonCoordinates}) async {
    await fetchProperties();

    List<MapPropertyModel> currentPropertiesToFilter = List.from(properties);

    if (propertyIds != null && propertyIds.isNotEmpty) {
      currentPropertiesToFilter = currentPropertiesToFilter
          .where((p) => propertyIds.contains(p.id))
          .toList();
    } else {}

    if (polygonCoordinates != null && polygonCoordinates.isNotEmpty) {
      clearDrawing();

      drawSavedPolygon(polygonCoordinates);
    } else {
      print(
          "SearchControllerMine: setFilterData - No new saved polygon. Checking for existing manual drawing.");
      if (polygons.isNotEmpty) {
      } else {
        clearDrawing();
      }
    }

    if (drawingPoints.isNotEmpty) {
      print(
          "SearchControllerMine: setFilterData - Applying spatial filter based on drawingPoints.");
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
      print(
          "SearchControllerMine: setFilterData - No spatial filter applied. Assigning current properties.");
    }
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
      // currentPosition.value = LatLng(position.latitude, position.longitude);
      if (moveToPosition && isMapReady) {
        mapController.move(userLocation.value!, 15.0);
      }
    } catch (e) {}
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
          // CustomWidgets.showSnackBar(
          //     'login_error', 'notFoundHouse', Colors.red);
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
      // CustomWidgets.showSnackBar('login_error', "noConnection2", Colors.red);
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
    if (!isLoading.value) {
      if (userLocation.value != null) {
        mapController.move(userLocation.value!, currentZoom.value);
      } else {
        _fitMapToMarkers();
      }
    }
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
  }

  void onPanStart(DragStartDetails details) {
    if (!isDrawingMode.value) return;

    filteredProperties.clear();
    polygons.clear();
    polylines.clear();
    drawingPoints.clear();
    drawingOffsets.clear();
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
      print("Map rotate hata: $e");
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
      final latlng =
          mapController.camera.pointToLatLng(Point(offset.dx, offset.dy));
      drawingPoints.add(latlng);
    }

    isDrawingMode.value = false;

    if (drawingPoints.length < 3) {
      clearDrawing();
      return;
    }

    if (drawingPoints.first != drawingPoints.last) {
      drawingPoints.add(drawingPoints.first);
    }

    _filterAndCreateSimpleMarkers();
    _createMaskAndBorder();
    drawingOffsets.clear(); // Clear the temporary drawing line
  }

  void _filterAndCreateSimpleMarkers() {
    print(
        "SearchControllerMine: _filterAndCreateSimpleMarkers called. Polygons for filtering: ${polygons.map((p) => p.points).toList()}"); // Added print
    final newFilteredList = <MapPropertyModel>[];
    for (var property in filteredProperties) {
      if (property.long != null && property.lat != null) {
        final point = LatLng(property.lat!, property.long!);
        bool isInAnyPolygon = false;
        for (final polygon in polygons) {
          // Iterate through each drawn polygon
          if (isPointInPolygon(point, polygon.points)) {
            isInAnyPolygon = true;
            break; // Found in one polygon, no need to check others
          }
        }
        if (isInAnyPolygon) {
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

  bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
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

  void drawSavedPolygon(List<dynamic> coordinates) {

    if (coordinates.isEmpty) {

      return;
    }

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
              color: Colors.blue.withOpacity(0.4),
              borderStrokeWidth: 4.0,
              borderColor: Colors.blue,
              isFilled: true,
            ));

            drawingPoints.addAll(
                currentPolygonPoints); 

          } else {

          }
          currentPolygonPoints.clear();
        } else {
          currentPolygonPoints.add(LatLng(lat, long));
        }
      }

      if (currentPolygonPoints.length >= 3) {
        polygons.add(Polygon(
          points: List.from(currentPolygonPoints),
          color: Colors.blue.withOpacity(0.4),
          borderStrokeWidth: 4.0,
          borderColor: Colors.blue,
          isFilled: true,
        ));

        drawingPoints.addAll(currentPolygonPoints);

      } else if (currentPolygonPoints.isNotEmpty) {

      }

      if (polygons.isNotEmpty) {

        filterPropertiesByPolygons();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isMapReady) {
            final allPoints = polygons.expand((p) => p.points).toList();
            if (allPoints.isNotEmpty) {
              mapController.fitCamera(
                CameraFit.coordinates(
                  coordinates: allPoints,
                  padding: EdgeInsets.all(50),
                ),
              );

            }
          } else {

          }
        });
      } else {

      }
    } catch (e) {
  
    }
  }

  Future<void> searchByAddress(String address) async {
    if (address.isEmpty) {
      filteredProperties.assignAll(properties);
      return;
    }
    isLoading.value = true;
    try {
      final fetchedProperties =
          await _propertyService.searchPropertiesByAddress(address);
      filteredProperties.assignAll(fetchedProperties);
      _fitMapToMarkers();
    } catch (e) {
      print(e);
      CustomWidgets.showSnackBar(
          'Error', 'Failed to search properties: $e', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
}
