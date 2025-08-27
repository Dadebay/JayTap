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
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Saýlanan ýeri tassyklamak isleýärsiňizmi?',
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Ýok'),
                    style: ElevatedButton.styleFrom(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onLocationSelectedCallback(selectedLatLng);
                      Get.back(); // Close bottom sheet
                    },
                    child: const Text('Hawa'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onFloatingActionButtonPressed() {
    if (selectedLocation.value != null) {
      _showConfirmationBottomSheet(selectedLocation.value!);
    } else {
      Get.snackbar(
        'Hata',
        'Lütfen haritada bir yer seçin.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
