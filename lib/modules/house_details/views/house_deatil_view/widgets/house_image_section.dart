import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/photo_view_screen.dart';

class HouseImageSection extends StatelessWidget {
  const HouseImageSection({Key? key, required this.house}) : super(key: key);
  final PropertyModel house;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => PhotoViewScreen(imageUrl: house.img!));
      },
      child: Stack(
        children: [
          house.img != null && house.img!.isNotEmpty ? Image.network(
            house.img!,
            height: 261,
            width: double.infinity,
            fit: BoxFit.cover,
          ) : Container(height: 261, width: double.infinity, color: Colors.grey[200], child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey[400])),
          Positioned(
            top: 10,
            left: 16,
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
                  icon: Icon(
                    IconlyLight.arrowLeft,
                    size: 30,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  padding: const EdgeInsets.all(8),
                )),
          ),
          Positioned(
            top: 10,
            right: 16,
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
                  icon: const Icon(
                    IconlyBold.heart,
                    size: 30,
                    color: Color.fromARGB(255, 230, 30, 77),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  padding: const EdgeInsets.all(8),
                )),
          ),
          Positioned(
              bottom: 10,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 34, 34, 34).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  '8/15',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}