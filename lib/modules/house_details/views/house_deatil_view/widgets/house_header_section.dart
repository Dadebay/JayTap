import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';

class HouseHeaderSection extends StatelessWidget {
  const HouseHeaderSection({Key? key, required this.house}) : super(key: key);
  final PropertyModel house;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: house.vip == true
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(250, 245, 132, 1),
                  Color.fromRGBO(255, 254, 199, 1),
                  Color.fromRGBO(255, 249, 224, 1),
                  Color.fromRGBO(255, 255, 255, 1),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            )
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
      child: Padding(
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
            Row(
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
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
              if (house.vip == true) Image.asset("assets/images/vip.png"),
            ]),
          ],
        ),
      ),
    );
  }
}
