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

class RealtorListView extends StatelessWidget {
  RealtorListView({super.key});

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    return Container(
      height: isTablet ? 120 : 85,
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0.0),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final double avatarSize = isTablet ? 100 : 85;
    final double fontSize = isTablet ? 10.sp : 12.sp;

    return GestureDetector(
      onTap: () {
        Get.to(() => RealtorsProfileView(realtor: realtor));
      },
      child: Container(
        width: avatarSize,
        margin: const EdgeInsets.symmetric(horizontal: 6),
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
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) {
                return Container(
                    width: avatarSize,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode
                            ? Colors.transparent
                            : context.greyColor.withOpacity(.3),
                        border: Border.all(
                            color: context.whiteColor.withOpacity(.5)),
                        boxShadow: []),
                    child: Icon(IconlyLight.infoSquare));
              },
            )),
            Text(
              realtor.name ?? '',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
