import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class FullScreenMapController extends GetxController {
  final mapController = MapController();
  Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);

  RxBool isLoadingLocation = false.obs;
  final Rx<LatLng?> userLocation = Rx(null);
  bool isMapReady = true;

  final Function(LatLng) onLocationSelectedCallback;
  final LatLng? initialLocation;
  final LatLng? userCurrentLocation;

  FullScreenMapController({
    required this.onLocationSelectedCallback,
    this.initialLocation,
    this.userCurrentLocation,
  });

  @override
  void onInit() {
    super.onInit();
    selectedLocation.value = initialLocation;
  }

  Future<void> findAndMoveToCurrentUserLocation() async {
    if (isLoadingLocation.value) return;

    try {
      isLoadingLocation.value = true;
      await _determinePositionAndMove(moveToPosition: true);
    } catch (e) {
    } finally {
      isLoadingLocation.value = false;
    }
  }

  Future<void> _determinePositionAndMove({required bool moveToPosition}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
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
    } catch (e) {}
  }

  void onMapTap(TapPosition tapPosition, LatLng latLng) {
    selectedLocation.value = latLng;
    print('Seçilen Konum: Lat: ${latLng.latitude}, Long: ${latLng.longitude}');
    _showConfirmationBottomSheet(latLng);
  }

  void _showConfirmationBottomSheet(LatLng selectedLatLng) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
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

            // Butonlar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
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
                      'no'.tr,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
