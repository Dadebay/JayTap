import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panorama/panorama.dart';

class PanoramaController extends GetxController {
  final _imagePath = 'assets/1.png'.obs;
  String get imagePath => _imagePath.value;

  void changeImage(String newImage) {
    _imagePath.value = newImage;
  }
}

class MuseumPanoramaPage extends StatelessWidget {
  const MuseumPanoramaPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(PanoramaController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('360° Museum Tour'),
      ),
      body: Obx(() {
        final controller = Get.find<PanoramaController>();
        return Panorama(
          animSpeed: 0.1,
          sensorControl: SensorControl.AbsoluteOrientation,
          sensitivity: 0.1,
          child: Image.asset(controller.imagePath),
          hotspots: [
            Hotspot(
              latitude: -15.0,
              longitude: -120.0,
              width: 90.0,
              height: 75.0,
              widget: HotspotButton(
                text: "Go to Room 2",
                onPressed: () => controller.changeImage('assets/2.png'),
              ),
            ),
            Hotspot(
              latitude: -10.0,
              longitude: 0.0,
              width: 90.0,
              height: 75.0,
              widget: HotspotButton(
                text: "Go to Room 1",
                onPressed: () => controller.changeImage('assets/1.png'),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class HotspotButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const HotspotButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(const CircleBorder()),
            backgroundColor: MaterialStateProperty.all(Colors.black.withOpacity(0.7)),
            foregroundColor: MaterialStateProperty.all(Colors.white),
          ),
          onPressed: onPressed,
          child: const Icon(Icons.open_in_new),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            backgroundColor: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
