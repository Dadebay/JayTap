import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/house_location_view.dart';

class HeaderSection extends StatelessWidget {
  final PropertyModel house;

  const HeaderSection({required this.house, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${house.price} TMT',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 0, 155, 0)),
              ),
              Text(
                '${house.category?.titleTk ?? ''}',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 0, 155, 0)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(house.name ?? '',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 33, 33, 33))),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              final lat = house.lat ?? 37.9234;
              final long = house.long ?? 58.4137;
              Get.to(() => HouseLocationView(lat: lat, long: long));
            },
            child: Row(
              children: [
                const Icon(
                  IconlyLight.location,
                  size: 20,
                  color: Color.fromARGB(255, 0, 155, 0),
                ),
                const SizedBox(width: 4),
                Text(house.address ?? '',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(255, 33, 33, 33))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                IconlyLight.show,
                size: 20,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              const SizedBox(width: 4),
              Text('Görülen: ${house.viewcount ?? 0}',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color.fromARGB(255, 33, 33, 33))),
            ],
          ),
        ],
      ),
    );
  }
}
