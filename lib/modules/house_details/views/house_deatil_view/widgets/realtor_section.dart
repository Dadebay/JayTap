import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/models/realtor_model.dart';
import 'package:jaytap/modules/home/views/pages/realtors_profil_view.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/shared/extensions/packages.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class RealtorSection extends StatelessWidget {
  final OwnerModel owner;
  const RealtorSection({Key? key, required this.owner}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: GestureDetector(
        onTap: () {
          final realtor = RealtorModel(
            id: owner.id,
            username: owner.username ?? '',
            typeTitle: owner.typeTitle,
            img: owner.imgUrl,
            name: owner.name,
            blok: false,
            address: '',
            rating: owner.rating?.toString(),
            userStatusChanging: '',
          );
          Get.to(() => RealtorsProfileView(realtor: realtor));
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage(
                  owner.imgUrl ?? '',
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    owner.name ?? '',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(children: [
                    Text(
                      'type_${owner.typeTitle}'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Text(
                    "+993 ${owner.username ?? ''}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                IconlyLight.arrowRightCircle,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
