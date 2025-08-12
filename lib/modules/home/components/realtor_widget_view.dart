// lib/modules/home/components/realtor_widget_view.dart (TÜMÜYLE GÜNCELLENDİ)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/home/models/realtor_model.dart';
import 'package:jaytap/modules/home/views/pages/realtors_profil_view.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:kartal/kartal.dart';

class RealtorListView extends StatelessWidget {
  RealtorListView({super.key});

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      child: Obx(() {
        if (controller.isLoadingRealtors.value) {
          return CustomWidgets.loader();
        }

        if (controller.realtorList.isEmpty) {
          return CustomWidgets.errorFetchData();
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0.0),
          itemCount: controller.realtorList.length,
          itemBuilder: (context, index) {
            final realtor = controller.realtorList[index];
            return RealtorAvatar(
              realtor: realtor,
            );
          },
        );
      }),
    );
  }
}

class RealtorAvatar extends StatelessWidget {
  final RealtorModel realtor;

  const RealtorAvatar({
    super.key,
    required this.realtor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Get.to(() => RealtorsProfileView(realtor: realtor));
      },
      child: Container(
        width: 85,
        margin: context.padding.low.copyWith(top: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: CachedNetworkImage(
              imageUrl: realtor.img!,
              imageBuilder: (context, imageProvider) => Container(
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.whiteColor),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) {
                return Container(width: 85, decoration: BoxDecoration(shape: BoxShape.circle, color: isDarkMode ? Colors.transparent : context.greyColor.withOpacity(.3), border: Border.all(color: context.whiteColor.withOpacity(.5)), boxShadow: []), child: Icon(IconlyLight.infoSquare));
              },
            )),
            Text(
              realtor.name ?? 'İsimsiz',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
