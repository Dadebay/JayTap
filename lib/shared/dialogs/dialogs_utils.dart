// ignore_for_file: inference_failure_on_function_return_type, inference_failure_on_function_invocation, duplicate_ignore, unused_local_variable

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/modules/auth/views/connection_check_view.dart';
import 'package:jaytap/modules/house_details/controllers/house_details_controller.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/widgets/agree_button.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:kartal/kartal.dart';

class DialogUtils {
  void showZalobaDialog(
      BuildContext context, HouseDetailsController controller, int houseID) {
    controller.fetchZalobaReasons();

    Get.defaultDialog(
        title: "zalobTitle".tr,
        titlePadding: const EdgeInsets.all(20),
        contentPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        content: SizedBox(
          width: Get.width * 0.8,
          child: Obx(() {
            if (controller.isLoadingZaloba.value) {
              return CustomWidgets.loader();
            }
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final reason in controller.zalobaReasons)
                    RadioListTile<int>(
                      title: Text(reason.localizedName),
                      value: reason.id,
                      groupValue: controller.selectedZalobaId.value,
                      onChanged: controller.selectZaloba,
                    ),
                  RadioListTile<int>(
                    title: Text("zalobSubtitle".tr),
                    value: controller.otherOptionId,
                    groupValue: controller.selectedZalobaId.value,
                    onChanged: controller.selectZaloba,
                  ),
                  if (controller.selectedZalobaId.value ==
                      controller.otherOptionId)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextField(
                        controller: controller.customZalobaController,
                        decoration: InputDecoration(
                          labelText: "zalobSubtitleWrite".tr,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        maxLines: 3,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        confirm: Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(elevation: 0.0),
              onPressed: () {
                if (controller.selectedZalobaId.value == null) {
                  CustomWidgets.showSnackBar(
                      "error".tr, "login_error".tr, Colors.red);
                } else {
                  controller.submitZaloba(houseId: houseID);
                }
              },
              child: controller.isSubmittingZaloba.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      "send".tr,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
            )),
        cancel: TextButton(
          onPressed: () => Get.back(),
          child: Text(
            "no".tr,
            style: TextStyle(
                color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ));
  }

  static void showSuccessDialog(BuildContext context) {
    final UserProfilController userProfileController =
        Get.find<UserProfilController>();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: context.border.normalBorderRadius),
        child: Container(
          padding:
              EdgeInsets.only(left: 20.w, right: 20.w, top: 40.h, bottom: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60.sp,
              ),
              SizedBox(height: 20.h),
              Text(
                "waitForAdminAnswer".tr,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontSize: 18.sp,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                child: AgreeButton(
                    onTap: () {
                      userProfileController.selectedTarifs.value =
                          <String>["type_4"].obs;
                      Get.back();
                    },
                    text: "agree3"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showTarifDialog(
    BuildContext context, {
    required List<String> tarifOptions,
    required List<String> initialSelectedTarifs,
    required Future<void> Function(List<String>) onConfirm,
  }) {
    final List<String> currentSelections =
        List<String>.from(initialSelectedTarifs);

    Get.dialog(Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: context.border.lowBorderRadius),
      child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Container(
          padding: context.padding.normal,
          width: Get.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...tarifOptions.map((option) {
                return CheckboxListTile(
                  title: Text(
                    option.toString().tr,
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.normal),
                  ),
                  value: currentSelections.contains(option),
                  activeColor: context.primaryColor,
                  onChanged: (bool? isChecked) {
                    setState(() {
                      currentSelections.clear();
                      currentSelections.add(option);
                    });
                  },
                );
              }).toList(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: AgreeButton(
                    onTap: () async {
                      await onConfirm(currentSelections);
                      Get.back();
                      DialogUtils.showSuccessDialog(context);
                    },
                    text: "agree3"),
              ),
            ],
          ),
        );
      }),
    ));
  }

  static showImagePicker(BuildContext context, ImagePicker picker) {
    Get.bottomSheet(
      Container(
        height: 380,
        decoration: BoxDecoration(
          color: context.whiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 40),
                  Text(
                    "uploadImage".tr,
                    style: context.textTheme.bodyMedium!.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: context.greyColor),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: context.blackColor),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOptionStatic(
                  context,
                  icon: Icons.camera_alt_outlined,
                  title: "byCamera",
                  onTap: () async {
                    Get.back();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.camera);
                  },
                ),
                _buildImagePickerOptionStatic(
                  context,
                  icon: IconlyLight.image2,
                  title: "Gallery",
                  onTap: () async {
                    Get.back();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 25),
              child: AgreeButton(onTap: () {}, text: "uploadImage"),
            )
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  static Widget _buildImagePickerOptionStatic(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: context.greyColor.withOpacity(.6),
        borderType: BorderType.RRect,
        radius: Radius.circular(10),
        child: Container(
          width: 150,
          height: 170,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 90, color: context.greyColor.withOpacity(.7)),
              SizedBox(height: 15),
              Text(
                title.tr,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: context.greyColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showNoConnectionDialog(
      {required VoidCallback onRetry, required BuildContext context}) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        actionsPadding: EdgeInsets.only(right: 5, bottom: 5),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'noConnection1'.tr,
              textAlign: TextAlign.start,
              maxLines: 1,
              style: context.general.textTheme.bodyLarge!
                  .copyWith(fontSize: 15.sp, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'noConnection2'.tr,
                textAlign: TextAlign.start,
                maxLines: 3,
                style: context.general.textTheme.bodyMedium!
                    .copyWith(fontSize: 14.sp),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              exit(0);
            },
            child: Text(
              'onRetryCancel'.tr,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: context.general.textTheme.bodyMedium!
                  .copyWith(fontSize: 13.sp, color: context.greyColor),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'onRetry'.tr,
              textAlign: TextAlign.center,
              maxLines: 1,
              style: context.general.textTheme.bodyMedium!
                  .copyWith(fontSize: 13.sp, color: context.blackColor),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void logOut(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final UserProfilController userProfilController =
        Get.find<UserProfilController>();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(10),
        color: isDarkMode
            ? Theme.of(context).colorScheme.surface
            : context.whiteColor,
        child: Wrap(
          children: [
            Center(
              child: Text(
                'log_out'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 20, top: 20, left: 20, right: 20),
              child: Center(
                child: Text(
                  'log_out_title'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                Get.offAll(() => ConnectionCheckView());

                await userProfilController.deleteAccount();
              },
              child: Container(
                width: Get.size.width,
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: context.greyColor.withOpacity(.3),
                    borderRadius: context.border.lowBorderRadius),
                child: Text(
                  'yes'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.whiteColor, fontSize: 16),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                Get.back();
              },
              child: Container(
                width: Get.size.width,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: context.redColor,
                    borderRadius: context.border.lowBorderRadius),
                child: Text(
                  'no'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: context.whiteColor, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void changeLanguage(BuildContext context) {
    final UserProfilController userProfileController =
        Get.find<UserProfilController>();

    final languages = [
      {'code': 'tr', 'label': 'Türkmen', 'icon': IconConstants.tmIcon},
      {'code': 'ru', 'label': 'Русский', 'icon': IconConstants.ruIcon},
      {'code': 'en', 'label': 'English', 'icon': IconConstants.usaIcon},
    ];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(bottom: 20, top: 10),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: Wrap(
          children: [
            Container(
              width: Get.size.width,
              child: Text(
                'select_language'.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600, fontSize: 18.sp),
              ),
            ),
            ...languages.map(
              (lang) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: ListTile(
                  onTap: () {
                    userProfileController.switchLang(lang['code']!);
                    Get.back();
                  },
                  trailing: Icon(IconlyLight.arrowRightCircle),
                  title: Text(
                    lang['label']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
