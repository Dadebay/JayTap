import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:photo_view/photo_view.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewScreen extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const PhotoViewScreen(
      {super.key, required this.imageUrls, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: imageUrls.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrls[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(color: Colors.white),
            pageController: PageController(initialPage: initialIndex),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                  icon: const Icon(IconlyLight.arrowLeftCircle,
                      color: Colors.black),
                  onPressed: () {
                    Get.back();
                  },
                  padding: const EdgeInsets.all(8)),
            ),
          ),
        ],
      ),
    );
  }
}
