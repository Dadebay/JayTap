import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/modules/house_details/controllers/full_screen_map_controller.dart';
import 'package:latlong2/latlong.dart';

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
    final controller = Get.put(FullScreenMapController(
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
              initialCenter: controller.initialLocation ?? LatLng(37.95, 58.38),
              initialZoom: 15.0,
              onTap: controller.onMapTap,
              onMapReady: () {
                controller.isMapReady = true; // Harita hazır olduğunda
                if (controller.userLocation.value != null) {
                  controller.mapController.move(controller.userLocation.value!, controller.currentZoom.value);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: ApiConstants.mapUrl,
                maxZoom: 18,
                minZoom: 5,
                keepBuffer: 8,
                panBuffer: 2,
                userAgentPackageName: 'com.gurbanov.jaytap',
                errorTileCallback: (tile, error, stackTrace) {
                  print('Tile yükleme hatası: $error');
                },
              ),
              Obx(() {
                if (controller.userLocation.value != null) {
                  return MarkerLayer(
                    markers: [
                      Marker(
                        point: controller.userLocation.value!,
                        width: 15,
                        height: 15,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1)],
                          ),
                          padding: const EdgeInsets.all(1),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
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
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(IconlyLight.arrowLeftCircle, color: Colors.black),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Obx(() {
                return GestureDetector(
                  onTap: controller.isLoadingLocation.value
                      ? null
                      : () async {
                          await controller.findAndMoveToCurrentUserLocation();
                        },
                  child: Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: controller.isLoadingLocation.value
                        ? CircularProgressIndicator(strokeWidth: 2)
                        : Image.asset(
                            'assets/icons/findMe.png',
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 24,
                            height: 24,
                          ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}