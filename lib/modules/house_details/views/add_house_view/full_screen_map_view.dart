import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/api_constants.dart';
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
              initialCenter: LatLng(37.95, 58.38),
              initialZoom: 15.0,
              onTap: controller.onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: ApiConstants.mapUrl,
                maxZoom: 18,
                minZoom: 5,
                userAgentPackageName: 'com.gurbanov.jaytap',
                errorTileCallback: (tile, error, stackTrace) {},
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
        ],
      ),
    );
  }
}
