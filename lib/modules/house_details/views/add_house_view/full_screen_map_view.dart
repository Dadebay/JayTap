import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:jaytap/modules/house_details/controllers/full_screen_map_controller.dart';

class FullScreenMapView extends GetView<FullScreenMapController> {
  final LatLng? initialLocation;
  final Function(LatLng) onLocationSelected;
  final LatLng? userCurrentLocation;

  const FullScreenMapView({
    super.key,
    this.initialLocation,
    required this.onLocationSelected,
    this.userCurrentLocation,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(FullScreenMapController(
      onLocationSelectedCallback: onLocationSelected,
      initialLocation: initialLocation,
      userCurrentLocation: userCurrentLocation,
    ));

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
              initialCenter: initialLocation ?? const LatLng(37.95, 58.38),
              initialZoom: 13.0,
              onTap: controller.onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.gurbanov.jaytap',
              ),

              Obx(() => controller.selectedLocation.value != null
                  ? MarkerLayer(
                      markers: [
                        Marker(
                          point: controller.selectedLocation.value!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            IconlyBold.location,
                            color: Colors.blueAccent,
                            size: 32,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink()),
              // Kullanıcının Mevcut Konumu Marker
              if (userCurrentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: userCurrentLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        IconlyBold.location,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Floating Action Button
          Positioned(
            right: 16.0,
            bottom: 16.0,
            child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onPressed: () {
                if (controller.selectedLocation.value != null) {
                  controller.onFloatingActionButtonPressed();
                } else {
                  Get.snackbar(
                    'Hata',
                    'Lütfen haritada bir yer seçin.',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(12),
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                    icon:
                        const Icon(IconlyBold.infoCircle, color: Colors.white),
                  );
                }
              },
              child: const Icon(IconlyBold.send, size: 28, color: Colors.white),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(IconlyLight.arrowLeft2, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
