import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/house_details_view.dart';
import 'package:jaytap/modules/user_profile/views/edit_profile_view.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/sizes/image_sizes.dart';
import 'package:kartal/kartal.dart';
import 'package:lottie/lottie.dart';

class CustomWidgets {
  static Center loader() {
    return Center(
        child: Lottie.asset(IconConstants.loading,
            width: 150, height: 150, animate: true));
  }

  static Center errorFetchData() {
    return Center(child: Text("errorFetchData"));
  }

  static Center emptyData() {
    return Center(child: Text("emptyData"));
  }

  static Center emptyDataWithLottie(
      {required String title,
      required String subtitle,
      required String lottiePath,
      bool? makeBigger,
      bool? showGif}) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              showGif == true
                  ? Image.asset(lottiePath,
                      width: makeBigger == true ? 300 : 150,
                      height: makeBigger == true ? 300 : 150)
                  : Lottie.asset(lottiePath,
                      width: makeBigger == true ? 300 : 150,
                      height: makeBigger == true ? 300 : 150,
                      animate: true),
              SizedBox(height: 16),
              Text(title.tr,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(subtitle.tr,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 17, color: ColorConstants.greyColor)),
            ],
          ),
        ),
      ),
    );
  }

  static OutlineInputBorder buildOutlineInputBorder({Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: borderColor ?? Colors.grey, width: 1),
    );
  }

  Widget drawerButton() {
    return Builder(
      builder: (context) {
        return IconButton(
          onPressed: () {
            Scaffold.of(context).openEndDrawer();
          },
          icon: Icon(Icons.menu),
        );
      },
    );
  }

  Center imageSelector({
    required BuildContext context,
    String? imageUrl,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fullImageUrl = imageUrl != null ? imageUrl : "";
    return Center(
      child: GestureDetector(
        onTap: () {
          Get.to(() => EditProfileView());
        },
        child: Stack(
          children: [
            Container(
              padding: context.padding.low,
              width: WidgetSizes.size128.value,
              alignment: Alignment.bottomCenter,
              height: WidgetSizes.size128.value,
              child: CachedNetworkImage(
                  imageUrl: fullImageUrl, // API'den gelen resim URL'si
                  imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover))),
                  alignment: Alignment.bottomCenter,
                  placeholder: (context, url) => CustomWidgets.loader(),
                  errorWidget: (context, url, error) => Image.asset(
                      IconConstants.noImageUser,
                      width: WidgetSizes.size128.value,
                      height: WidgetSizes.size128.value,
                      fit: BoxFit.cover)),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                  decoration: BoxDecoration(
                      color: isDarkMode
                          ? context.whiteColor
                          : context.primaryColor,
                      shape: BoxShape.circle),
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.edit,
                      size: 18,
                      color: isDarkMode
                          ? context.blackColor
                          : context.whiteColor)),
            )
          ],
        ),
      ),
    );
  }

  Widget logo(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: context.padding.normal,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Colors.transparent,
            boxShadow: [
              // BoxShadow(color: isDarkMode ? context.whiteColor.withOpacity(.5) : context.greyColor.withOpacity(.5), blurRadius: 10),
            ]),
        child: Container(
          height: 200,
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: isDarkMode ? context.blackColor : context.whiteColor),
          child: Image.asset(
            IconConstants.appLogoWhtie,
          ),
        ),
      ),
    );
  }

  static Widget marketWidget(
      {required BuildContext context,
      required int houseID,
      required String price,
      required String type}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Get.to(() => HouseDetailsView(houseID: houseID, myHouses: false));
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                )
              ],
            ),
            child: Text(
              price + " TMT",
              maxLines: 1,
              style: TextStyle(
                fontSize: 10.sp,
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: type == "satlyk"
                    ? ColorConstants.kPrimaryColor
                    : Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ))
        ],
      ),
    );
  }

  static ClipRRect imagePlaceHolder() => ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(IconConstants.noImage, fit: BoxFit.cover));
  static Expanded miniCard(
      BuildContext context, String text1, String text2, bool premium) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isDarkMode ? context.blackColor : context.whiteColor,
            gradient: premium
                ? LinearGradient(
                    colors: [Colors.yellow, Colors.white],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter)
                : null,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: ColorConstants.kPrimaryColor.withOpacity(.3)),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? context.whiteColor.withOpacity(.5)
                    : ColorConstants.blackColor.withOpacity(.1),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          padding: EdgeInsets.only(top: 8, bottom: 4, left: 6, right: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  text1,
                  style: context.textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 17.sp),
                ),
              ),
              Expanded(
                child: Text(
                  text2.tr,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w400,
                      color: context.greyColor,
                      fontSize: 15.sp),
                ),
              ),
            ],
          )),
    );
  }

  static showSnackBar(String title, String subtitle, Color color) {
    Get.snackbar(
      title,
      subtitle,
      snackStyle: SnackStyle.FLOATING,
      titleText: title == ''
          ? const SizedBox.shrink()
          : Text(
              title.tr,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
      messageText: Text(
        subtitle.tr,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: color,
      borderRadius: 20.0,
      duration: const Duration(milliseconds: 1000),
      margin: const EdgeInsets.all(8),
    );
  }

  static Widget imageWidget(String? url, bool fit, bool? miniBorderRadius) {
    return CachedNetworkImage(
      imageUrl: url!,
      width: Get.size.width,
      imageBuilder: (context, imageProvider) => Container(
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(miniBorderRadius == true ? 16 : 20),
          image: DecorationImage(
            image: imageProvider,
            fit: fit ? null : BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) {
        return Icon(IconlyLight.infoSquare);
      },
    );
  }

  static Widget listViewTextWidget(
      {required String text,
      required bool removeIcon,
      required Function() ontap}) {
    return Padding(
      padding: EdgeInsets.only(right: 16, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          removeIcon
              ? SizedBox.shrink()
              : IconButton(
                  onPressed: ontap, icon: Icon(IconlyLight.arrowRightCircle)),
        ],
      ),
    );
  }
}
