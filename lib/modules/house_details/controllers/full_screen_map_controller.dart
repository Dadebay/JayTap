import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class FullScreenMapController extends GetxController {
  final mapController = MapController();
  Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  RxDouble currentZoom = 15.0.obs; // Varsayılan zoom 15 olarak ayarlandı
  RxBool isLoadingLocation = false.obs;
  final Rx<LatLng?> userLocation = Rx(null);
  bool isMapReady = false;

  final Function(LatLng) onLocationSelectedCallback;
  final LatLng? initialLocation;
  final LatLng? userCurrentLocation;

  Rx<LatLng> currentPosition = LatLng(37.9601, 58.3261).obs; // Varsayılan konum

  FullScreenMapController({
    required this.onLocationSelectedCallback,
    this.initialLocation,
    this.userCurrentLocation,
  });

  @override
  void onInit() {
    super.onInit();
    selectedLocation.value = initialLocation;
    if (userCurrentLocation != null) {
      userLocation.value = userCurrentLocation;
    }
  }

  @override
  void onReady() {
    super.onReady();
    isMapReady = true; // Harita hazır olduğunda bu true olacak
    // Otomatik konum aramasını kaldırdık

    if (userLocation.value != null && isMapReady) {
      mapController.move(userLocation.value!, currentZoom.value);
    }
  }

  Future<void> findAndMoveToCurrentUserLocation() async {
    isLoadingLocation.value = true;
    try {
      await _determinePositionAndMove(moveToPosition: true);
      if (userLocation.value != null && isMapReady) {
        mapController.move(
            userLocation.value!, currentZoom.value); // Doğrudan hareket
        Future.delayed(const Duration(milliseconds: 100), () {
          mapController.move(userLocation.value!,
              currentZoom.value); // Küçük bir gecikme ile tekrar
        });
      }
    } catch (e) {
      // Get.snackbar('Hata', 'Konum alınamadı: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
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

    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();

      if (status.isDenied) {
        Get.snackbar(
            'permission_denied_title'.tr, 'permission_denied_content'.tr);
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
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

    return true;
  }

  Future<void> _determinePositionAndMove({required bool moveToPosition}) async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 15), // Zaman aşımını artırdık
      );
    } catch (e) {
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
      } catch (e) {
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
        } catch (e) {
          Get.snackbar('Hata',
              'Konum alınamadı: $e. GPS veya internet bağlantısını kontrol edin.');
          return;
        }
      }
    }

    if (position case final Position currentPositionValue) {
      final newLocation =
          LatLng(currentPositionValue.latitude, currentPositionValue.longitude);
      userLocation.value = newLocation;
      currentPosition.value = newLocation;
      if (moveToPosition && isMapReady) {
        Future.delayed(const Duration(milliseconds: 300), () {
          // Gecikmeyi artırdık
          mapController.move(userLocation.value!, currentZoom.value);
        });
      }
    }
  }

  void onMapTap(TapPosition tapPosition, LatLng latLng) {
    selectedLocation.value = latLng;

    _showConfirmationBottomSheet(latLng);
  }

  void _showConfirmationBottomSheet(LatLng selectedLatLng) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.only(bottom: 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'select_location'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    child: Text(
                      'no'.tr,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onLocationSelectedCallback(selectedLatLng);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    child: Text(
                      'yes'.tr,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
