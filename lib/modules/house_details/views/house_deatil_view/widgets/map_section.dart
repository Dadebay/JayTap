import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/api_constants.dart';
// Model ve View dosyalarınızın yollarını kendi projenize göre güncelleyin
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/house_location_view.dart';
import 'package:latlong2/latlong.dart';

class MapSection extends StatelessWidget {
  const MapSection({Key? key, required this.house}) : super(key: key);
  final PropertyModel house;

  @override
  Widget build(BuildContext context) {
    if (house.lat == null || house.long == null) {
      return const SizedBox.shrink();
    }

    final lat = house.lat!;
    final long = house.long!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      height: 210,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.4) // Use onSurface for shadow in dark mode
                : Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, long),
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: ApiConstants.mapUrl,
                  maxZoom: 18,
                  minZoom: 5,
                  keepBuffer: 8,
                  panBuffer: 2,
                  userAgentPackageName: 'com.gurbanov.jaytap',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(lat, long),
                      child: Icon(
                        IconlyBold.location,
                        color: Theme.of(context).colorScheme.primary,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'section_11'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  Get.to(() => HouseLocationView(lat: lat, long: long));
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
