// import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jaytap/modules/house_details/models/property_model.dart';
// import 'package:jaytap/shared/widgets/widgets.dart';
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
//     if (currentVrImage.value?.id != newRoom.id) {
//       currentVrImage.value = newRoom;
//     }
//   }
//   //
// }

// class PanoramaViewPage extends StatelessWidget {
//   final List<VrModel> vrData;

//   const PanoramaViewPage({super.key, required this.vrData});

//   @override
//   Widget build(BuildContext context) {
//     final PanoramaController controller = Get.put(PanoramaController());
//     controller.initialize(vrData);

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         title: Obx(() => Text(controller.currentVrImage.value?.title ?? '360° View', style: TextStyle(color: Colors.white))),
//         backgroundColor: Colors.black.withOpacity(0.5),
//         elevation: 0,
//       ),
//       body: Obx(() {
//         if (controller.currentVrImage.value == null) {
//           return CustomWidgets.loader();
//         }

//         final currentImage = controller.currentVrImage.value!;

//         return Panorama(
//           animSpeed: 0.0,
//           sensorControl: SensorControl.None,
//           child: Image(
//             image: CachedNetworkImageProvider(currentImage.imageUrl),
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return Center(
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                     child: Container(
//                       width: 250,
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.6),
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Text(
//                             "Yeni oda yükleniyor...",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           LinearProgressIndicator(
//                             value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1) : null,
//                             backgroundColor: Colors.white.withOpacity(0.3),
//                             valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             // Yüzdeyi hesaplayıp gösteriyoruz
//                             '${((loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)) * 100).toStringAsFixed(0)}%',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//             errorBuilder: (context, error, stackTrace) {
//               return const Center(
//                   child: Text(
//                 "Failed to load image.",
//                 style: TextStyle(color: Colors.white),
//               ));
//             },
//           ),
//           hotspots: controller.vrData.where((room) => room.id != currentImage.id).map((room) {
//             return Hotspot(
//               latitude: room.lat,
//               longitude: room.long,
//               width: 120.0,
//               height: 100.0,
//               widget: HotspotButton(
//                 text: room.title,
//                 // Changed to call the new transition method
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
//     return GestureDetector(
//       onTap: onPressed,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(50),
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
//               child: Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
//                 ),
//                 child: const Icon(
//                   CupertinoIcons.arrow_right_circle,
//                   color: Colors.white,
//                   size: 30,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.6),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               text,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
