import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class FullScreenMapController extends GetxController {
  final mapController = MapController();
  Rx<LatLng?> selectedLocation = Rx<LatLng?>(null);

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
              'Saýlanan ýeri tassyklamak isleýärsiňizmi?',
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
                    child: const Text(
                      'Ýok',
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
                    child: const Text(
                      'Hawa',
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
