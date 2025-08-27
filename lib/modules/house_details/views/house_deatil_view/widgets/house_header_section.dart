import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/shared/extensions/packages.dart';

class HouseHeaderSection extends StatelessWidget {
  const HouseHeaderSection({Key? key, required this.house}) : super(key: key);
  final PropertyModel house;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: house.vip == true
          ? BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromRGBO(250, 245, 132, 1),
                  Color.fromRGBO(255, 254, 199, 1),
                  Color.fromRGBO(255, 249, 224, 1),
                  Color.fromRGBO(255, 255, 255, 1),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                ),
              ],
            )
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    house.name ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 32, 32, 32),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        house.price.toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        ' TMT',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(house.category?.name ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                )),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  IconlyLight.location,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(house.address ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                children: [
                  const Icon(
                    IconlyLight.show,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text('viewed'.tr + ' : ${house.viewcount ?? 0}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      )),
                ],
              ),
              // if (house.vip == true) Image.asset("assets/images/vip.png"),
            ]),
          ],
        ),
      ),
    );
  }
}
