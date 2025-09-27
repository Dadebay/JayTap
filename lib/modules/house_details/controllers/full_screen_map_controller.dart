import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class FullScreenMapController extends GetxController {
  final mapController = MapController();
  Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);
  RxDouble currentZoom = 12.0.obs;
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

  @override
  void onReady() {
    super.onReady();
    findAndMoveToCurrentUserLocation();
  }

  Future<void> findAndMoveToCurrentUserLocation() async {
    isLoadingLocation.value = true;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final loc = await Geolocator.getCurrentPosition(timeLimit: const Duration(seconds: 15));
        userLocation.value = LatLng(loc.latitude, loc.longitude);
        mapController.move(userLocation.value!, currentZoom.value);
      } else {
        Get.snackbar('permission_denied'.tr, 'location_permission_not_granted'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'error_getting_location'.tr);
    } finally {
      isLoadingLocation.value = false;
    }
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
