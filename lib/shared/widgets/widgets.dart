import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/house_details/views/house_details_view.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/sizes/image_sizes.dart';
import 'package:kartal/kartal.dart';
import 'package:lottie/lottie.dart';

class CustomWidgets {
  static Center loader() {
    return Center(child: Lottie.asset(IconConstants.loading, width: 150, height: 150, animate: true));
  }

  static Center errorFetchData() {
    return Center(child: Text("errorFetchData"));
  }

  static Center emptyData() {
    return Center(child: Text("emptyData"));
  }

  static OutlineInputBorder buildOutlineInputBorder({Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: borderColor ?? Colors.grey, width: 1),
    );
  }

  Center imageSelector({required BuildContext context, String? imageUrl, required Function() onTap, required bool addPadding}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fullImageUrl = imageUrl != null ? ApiConstants.imageURL + imageUrl : "";

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(top: addPadding ? 50 : 0.0),
              padding: context.padding.low,
              width: WidgetSizes.size128.value,
              alignment: Alignment.bottomCenter,
              height: WidgetSizes.size128.value,
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: CachedNetworkImage(
                  imageUrl: fullImageUrl, // API'den gelen resim URL'si
                  imageBuilder: (context, imageProvider) => ClipRRect(
                        borderRadius: context.border.highBorderRadius,
                        child: Container(decoration: BoxDecoration(image: DecorationImage(image: imageProvider, fit: BoxFit.cover))),
                      ),
                  alignment: Alignment.bottomCenter,
                  placeholder: (context, url) => CustomWidgets.loader(),
                  errorWidget: (context, url, error) => Image.asset(IconConstants.noImageUser, width: WidgetSizes.size128.value, height: WidgetSizes.size128.value, fit: BoxFit.cover)),
            ),
            Positioned(
              bottom: 15,
              right: 5,
              child: Container(
                  decoration: BoxDecoration(color: isDarkMode ? context.whiteColor : context.primaryColor, shape: BoxShape.circle),
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.edit, size: 18, color: isDarkMode ? context.blackColor : context.whiteColor)),
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
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.transparent, boxShadow: [
          BoxShadow(color: isDarkMode ? context.whiteColor.withOpacity(.5) : context.greyColor.withOpacity(.5), blurRadius: 10),
        ]),
        child: Container(
          height: 200,
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: isDarkMode ? context.blackColor : context.whiteColor),
          child: Image.asset(
            IconConstants.appLogoWhtie,
          ),
        ),
      ),
    );
  }

  static Widget marketWidget({required BuildContext context, required int houseID, required String price, required String type}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print(type);
    return GestureDetector(
      onTap: () {
        Get.to(() => HouseDetailsView(houseID: houseID));
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
                color: type == "satlyk" ? ColorConstants.kPrimaryColor : Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ))
        ],
      ),
    );
  }

  static ClipRRect imagePlaceHolder() => ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(IconConstants.noImage, fit: BoxFit.cover));
  static Expanded miniCard(BuildContext context, String text1, String text2, bool premium) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isDarkMode ? context.blackColor : context.whiteColor,
            // gradient: premium ? LinearGradient(colors: ),
            borderRadius: context.border.lowBorderRadius,
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? context.whiteColor.withOpacity(.5) : context.primaryColor.withOpacity(.3),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text1,
                style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
              Text(
                text2.tr,
                style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400, color: context.greyColor, fontSize: 18.sp),
              ),
            ],
          )),
    );
  }

  static SnackbarController showSnackBar(String title, String subtitle, Color color) {
    if (SnackbarController.isSnackbarBeingShown) {
      SnackbarController.cancelAllSnackbars();
    }
    return Get.snackbar(
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

  static Widget imageWidget(String? url, bool fit) {
    return CachedNetworkImage(
      imageUrl: url!,
      width: Get.size.width,
      imageBuilder: (context, imageProvider) => Container(
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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

  static Widget listViewTextWidget({required String text, required bool removeIcon, required Function() ontap}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10, top: 20, right: 16, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text.tr,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          removeIcon ? SizedBox.shrink() : IconButton(onPressed: ontap, icon: Icon(IconlyLight.arrowRightCircle)),
        ],
      ),
    );
  }
}
