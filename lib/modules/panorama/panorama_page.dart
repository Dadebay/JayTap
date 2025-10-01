// import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
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

// // --- DEĞİŞİKLİK: StatefulWidget'a dönüştürüldü ---
// class PanoramaViewPage extends StatefulWidget {
//   final List<VrModel> vrData;

//   const PanoramaViewPage({super.key, required this.vrData});

//   @override
//   State<PanoramaViewPage> createState() => _PanoramaViewPageState();
// }

// class _PanoramaViewPageState extends State<PanoramaViewPage> {
//   @override
//   void initState() {
//     super.initState();
//     // Sayfa açıldığında tam ekran moduna geç (durum çubuğunu ve navigasyon çubuğunu gizle)
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     // Sayfadan çıkıldığında sistem arayüzünü geri getir
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final PanoramaController controller = Get.put(PanoramaController());
//     controller.initialize(widget.vrData); // 'widget.vrData' kullanılıyor

//     return Scaffold(
//       // extendBodyBehindAppBar artık tam ekran modunda daha anlamlı
//       extendBodyBehindAppBar: true,
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Obx(() => Text(controller.currentVrImage.value?.title ?? '', style: TextStyle(color: Colors.white))),
//         // AppBar'ı şeffaf yaparak tam ekran hissiyatını güçlendiriyoruz
//         backgroundColor: Colors.black.withOpacity(0.3),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: Obx(() {
//         if (controller.currentVrImage.value == null) {
//           return CustomWidgets.loader();
//         }

//         final currentImage = controller.currentVrImage.value!;

//         return Panorama(
//           animSpeed: 0.0,
//           zoom: 1.0,
//           croppedFullHeight: 1.0,
//           sensorControl: SensorControl.None,
//           child: Image(
//             image: CachedNetworkImageProvider(currentImage.imageUrl),
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return Center(
//                   child: ClipRRect(
//                 borderRadius: BorderRadius.circular(15),
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                   child: Container(
//                     width: 250,
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.6),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Text(
//                           "Yeni oda yükleniyor...",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         LinearProgressIndicator(
//                           value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1) : null,
//                           backgroundColor: Colors.white.withOpacity(0.3),
//                           valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           '${((loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)) * 100).toStringAsFixed(0)}%',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ));
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
//             borderRadius: BorderRadius.circular(10),
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
//             padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.6),
//               borderRadius: BorderRadius.circular(5),
//             ),
//             child: Text(
//               text,
//               textAlign: TextAlign.center,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
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
