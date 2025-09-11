import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:latlong2/latlong.dart';

// Widget'ı StatefulWidget'a dönüştürdük, çünkü MapController'ı yönetmemiz gerekiyor.
class HouseLocationView extends StatefulWidget {
  final double lat;
  final double long;

  const HouseLocationView({required this.lat, required this.long, super.key});

  @override
  State<HouseLocationView> createState() => _HouseLocationViewState();
}

class _HouseLocationViewState extends State<HouseLocationView> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.lat, widget.long),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: ApiConstants.mapUrl,
                maxZoom: 18,
                minZoom: 5,
                userAgentPackageName: 'com.gurbanov.jaytap',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(widget.lat, widget.long),
                    child: const Icon(
                      IconlyBold.location,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 50.0,
            left: 16.0,
            child: _buildCircularButton(
              icon: IconlyLight.arrowLeft,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
            bottom: 30.0,
            right: 16.0,
            child: Column(
              children: [
                _buildCircularButton(
                  icon: HugeIcons.strokeRoundedMaximize01,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildCircularButton(
                  icon: HugeIcons.strokeRoundedMinimize01,
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.black,
        onPressed: onPressed,
      ),
    );
  }
}
