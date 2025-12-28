// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/shared/extensions/packages.dart';

class HouseHeaderSection extends StatelessWidget {
  const HouseHeaderSection({
    Key? key,
    required this.house,
    required this.myHouses,
  }) : super(key: key);
  final PropertyModel house;
  final bool myHouses;

  void showCopySnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.copy_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'id_copied'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: house.vip == true
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 254, 212, 42).withOpacity(0.9)
                      : ColorConstants.premiumColor,
                  Colors.white.withOpacity(0.4)
                ],
                begin: Alignment.bottomRight,
                end: Alignment.topRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 2,
                  offset: const Offset(0, 0),
                ),
              ],
            )
          : BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(
                          0.4) // Use onSurface for shadow in dark mode
                      : Colors.grey.withOpacity(0.2),
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
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      Text(
                        ' TMT',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(house.category?.name ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      )),
                  if (myHouses)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        house.confirm == 'waiting'
                            ? 'status_waiting'.tr
                            : house.confirm == 'accepted'
                                ? 'status_accepted'.tr
                                : 'status_rejected'.tr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                ]),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  IconlyLight.location,
                  size: 16,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(house.address ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                children: [
                  Row(children: [
                    Icon(
                      IconlyLight.show,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text('viewed'.tr + ' : ${house.viewcount ?? 0}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        )),
                  ]),
                ],
              ),
              // if (myHouses)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    showCopySnackbar(context);

                    Future.delayed(const Duration(milliseconds: 200), () {
                      Clipboard.setData(
                          ClipboardData(text: house.id.toString()));
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '№: ${house.id}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
