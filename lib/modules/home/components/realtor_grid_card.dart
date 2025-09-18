import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/models/realtor_model.dart';
import 'package:jaytap/modules/home/views/pages/realtors_profil_view.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:kartal/kartal.dart';
import 'package:shimmer/shimmer.dart';

class RealtorGridCard extends StatelessWidget {
  final RealtorModel realtor;

  RealtorGridCard({super.key, required this.realtor});
  final UserProfilController userProfilController =
      Get.find<UserProfilController>();

  @override
  Widget build(BuildContext context) {
    final double ratingValue = double.tryParse(realtor.rating ?? '0.0') ?? 0.0;

    Widget shimmerAvatar() {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: CircleAvatar(
          radius: 45.r,
          backgroundColor: Colors.grey.shade300,
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => RealtorsProfileView(realtor: realtor));
      },
      child: Card(
        elevation: 3,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: context.border.normalBorderRadius,
          side: BorderSide(color: context.primaryColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar + Shimmer
              CircleAvatar(
                radius: 45.r,
                backgroundColor: context.primaryColor.withOpacity(0.2),
                child: CachedNetworkImage(
                  imageUrl: realtor.img ?? '',
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 43.r,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: CircleAvatar(
                      radius: 45.r,
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.person, size: 40.r, color: Colors.grey),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  realtor.name ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(IconlyBold.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    ratingValue.toStringAsFixed(1),
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: context.padding.verticalLow,
                child: Text(
                  userProfilController.getTarifText(realtor.typeTitle),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                ),
              ),
              realtor.address!.isEmpty
                  ? SizedBox.shrink()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(IconlyBold.location,
                            color: context.primaryColor, size: 16.sp),
                        const SizedBox(width: 4),
                        Text(
                          realtor.address.toString(),
                          style: context.textTheme.bodySmall!
                              .copyWith(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
