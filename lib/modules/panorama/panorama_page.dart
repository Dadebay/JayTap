// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jaytap/modules/house_details/models/property_model.dart';
// import 'package:panorama/panorama.dart';

// class PanoramaController extends GetxController {
//   final RxList<VrModel> vrData = <VrModel>[].obs;

//   final Rx<VrModel?> currentVrImage = Rx<VrModel?>(null);

//   void initialize(List<VrModel> data) {
//     if (data.isNotEmpty) {
//       vrData.assignAll(data);

//       currentVrImage.value = vrData.first;
//     }
//   }

//   void changeRoom(VrModel newRoom) {
//     currentVrImage.value = newRoom;
//   }
// }

// class PanoramaViewPage extends StatelessWidget {
//   final List<VrModel> vrData;

//   const PanoramaViewPage({super.key, required this.vrData});

//   @override
//   Widget build(BuildContext context) {
//     final PanoramaController controller = Get.put(PanoramaController());
//     controller.initialize(vrData);

//     return Scaffold(
//       appBar: AppBar(
//         title: Obx(() => Text(controller.currentVrImage.value?.title ?? '360° Görüntü')),
//       ),
//       body: Obx(() {
//         if (controller.currentVrImage.value == null) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final currentImage = controller.currentVrImage.value!;

//         return Panorama(
//           animSpeed: 0.1,
//           sensorControl: SensorControl.AbsoluteOrientation,
//           child: Image.network(
//             currentImage.imageUrl,
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return const Center(child: CircularProgressIndicator());
//             },
//             errorBuilder: (context, error, stackTrace) {
//               return const Center(child: Text("Resim yüklenemedi."));
//             },
//           ),
//           hotspots: controller.vrData.map((room) {
//             print(room.long);
//             print(room.lat);
//             if (room.id == currentImage.id) {
//               return Hotspot(latitude: 0, longitude: 0, width: 0, height: 0);
//             }
//             return Hotspot(
//               latitude: room.lat,
//               longitude: room.long,
//               width: 90.0,
//               height: 90.0,
//               widget: HotspotButton(
//                 text: room.title,
//                 onPressed: () => controller.changeRoom(room),
//               ),
//             );
//           }).toList(),
//         );
//       }),
//     );
//   }
// }

// class HotspotButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;

//   const HotspotButton({super.key, required this.text, required this.onPressed});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         TextButton(
//           style: ButtonStyle(
//             shape: WidgetStateProperty.all(const CircleBorder()),
//             backgroundColor: WidgetStateProperty.all(Colors.black.withOpacity(0.7)),
//             foregroundColor: WidgetStateProperty.all(Colors.white),
//           ),
//           onPressed: onPressed,
//           child: const Icon(Icons.open_in_new),
//         ),
//         const SizedBox(height: 4),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             text,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: Colors.red,
//               fontSize: 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
