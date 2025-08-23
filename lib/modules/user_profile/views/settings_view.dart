// settings_view.dart dosyasının güncel hali

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/components/properties_widget_view.dart';
import 'package:jaytap/modules/house_details/views/add_house_view/add_house_view.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';
import 'package:jaytap/modules/user_profile/model/user_model.dart';
import 'package:jaytap/modules/user_profile/views/edit_profile_view.dart';
import 'package:jaytap/modules/user_profile/views/user_profile_view.dart';
import 'package:jaytap/shared/dialogs/dialogs_utils.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/widgets/agree_button.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:kartal/kartal.dart';

class SettingsView extends StatefulWidget {
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final UserProfilController userProfileController = Get.find<UserProfilController>();

  @override
  void initState() {
    super.initState();
    userProfileController.fetchUserData();
    userProfileController.fetchMyProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: UserProfileView(),
      ),
      body: Obx(() {
        if (userProfileController.isLoading.value) return CustomWidgets.loader();
        if (userProfileController.user.value == null) return CustomWidgets.emptyData();
        final user = userProfileController.user.value!;
        return ListView(
          padding: context.padding.normal,
          children: [
            CustomWidgets().imageSelector(context: context, imageUrl: user.img),
            _content(context, user),
            Obx(() {
              if (userProfileController.isProductsLoading.value) {
                return CustomWidgets.loader();
              }
              if (userProfileController.myProducts.isEmpty) {
                return Center(child: Text("no_properties_found".tr));
              }

              return PropertiesWidgetView(isGridView: true, removePadding: true, properties: userProfileController.myProducts, inContentBanners: [], myHouses: true);
            }),
          ],
        );
      }),
    );
  }

  Column _content(BuildContext context, UserModel user) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          user.name,
          style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        Padding(
          padding: context.padding.verticalLow,
          child: Text(
            '+993' + user.username,
            style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500, color: context.greyColor, fontSize: 15.sp),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10).copyWith(top: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (index) {
                final ratingValue = double.tryParse(user.rating) ?? 0.0;
                if (index < ratingValue) {
                  return Icon(IconlyBold.star, color: Theme.of(context).colorScheme.tertiary, size: 16.sp);
                } else {
                  return Icon(IconlyBold.star, color: Theme.of(context).colorScheme.outline.withOpacity(.4), size: 16.sp);
                }
              }),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  user.rating,
                  style: context.textTheme.bodyMedium!.copyWith(color: context.greyColor.withOpacity(.7), fontWeight: FontWeight.w500, fontSize: 14.sp),
                ),
              )
            ],
          ),
        ),
        Container(
          height: 90,
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              CustomWidgets.miniCard(context, user.productCount, 'content', false),
              CustomWidgets.miniCard(context, user.viewCount, 'viewed', false),
              CustomWidgets.miniCard(context, user.premiumCount, 'premium', true),
            ],
          ),
        ),
        GestureDetector(
            onTap: () {
              final userStatus = userProfileController.user.value!.userStatusChanging;
              final isWaiting = userStatus != 'done';
              if (!isWaiting) {
                final List<String> filteredTarifOptions = userProfileController.tarifOptions.where((option) => option != 'type_5').toList();
                DialogUtils.showTarifDialog(
                  context,
                  tarifOptions: filteredTarifOptions,
                  initialSelectedTarifs: userProfileController.selectedTarifs.toList(),
                  // Değişiklik: Controller'daki yeni metodu çağırın
                  onConfirm: (List<String> finalSelections) async {
                    if (finalSelections.isNotEmpty) {
                      await userProfileController.updateUserTarif(finalSelections.first);
                    }
                  },
                );
              } else {
                CustomWidgets.showSnackBar("Beklenmedik durum", "Tarif değişikliği bekleniyor.", Theme.of(context).colorScheme.tertiary);
              }
            },
            child: Container(
                margin: EdgeInsets.all(12).copyWith(top: 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Theme.of(context).shadowColor.withOpacity(isDarkMode ? 0.5 : 0.3), blurRadius: 5, spreadRadius: 1)],
                ),
                padding: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      final userStatus = userProfileController.user.value!.userStatusChanging;
                      final isWaiting = userStatus != 'done';

                      final tarifText = isWaiting ? "type_5".tr : userProfileController.getTarifText(user.typeTitle);

                      return RichText(
                        text: TextSpan(
                          style: context.textTheme.bodyMedium!.copyWith(
                            fontSize: 16.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: "changeTarif".tr + ": ", style: context.textTheme.bodyMedium!.copyWith(color: context.greyColor, fontSize: 14.sp)),
                            TextSpan(
                              text: tarifText,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                                color: isWaiting ? Theme.of(context).colorScheme.tertiary : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    Icon(IconlyLight.arrowDownCircle, color: context.greyColor)
                  ],
                ))),
        TransparentColorButton(onTap: () => Get.to(() => AddHouseView()), icon: IconlyLight.plus, text: 'addContent'),
      ],
    );
  }
}
