// settings_view.dart dosyasının güncel hali

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/components/properties_widget_view.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';
import 'package:jaytap/modules/user_profile/model/user_model.dart';
import 'package:jaytap/modules/user_profile/views/edit_profile_view.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: SizedBox.shrink(),
      ),
      body: Obx(() {
        if (userProfileController.isLoading.value) return CustomWidgets.loader();
        if (userProfileController.user.value == null) return CustomWidgets.emptyData();
        final user = userProfileController.user.value!;
        return Stack(
          children: [
            ListView(
              padding: context.padding.normal,
              children: [
                CustomWidgets().imageSelector(context: context, imageUrl: user.img, onTap: () => Get.to(() => EditProfileView()), addPadding: true),
                _content(context, user),
                Obx(() {
                  if (userProfileController.isProductsLoading.value) {
                    return CustomWidgets.loader();
                  }
                  if (userProfileController.myProducts.isEmpty) {
                    return Center(child: Text("no_properties_found".tr)); // Çeviri anahtarı
                  }
                  // Mevcut PropertiesWidgetView'ı kullanarak ilanları gösteriyoruz
                  return PropertiesWidgetView(
                    isGridView: true, // Izgara görünümü için
                    removePadding: true, // ListView içinde olduğu için ekstra padding'i kaldır
                    properties: userProfileController.myProducts,
                    inContentBanners: [], // Burada banner olmayacak
                  );
                }),
              ],
            ),
            Positioned(
              top: 45,
              left: 15,
              child: IconButton(onPressed: () => Get.back(), icon: Icon(IconlyLight.arrowLeftCircle)),
            ),
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
                  return Icon(IconlyBold.star, color: Colors.amber, size: 16.sp);
                } else {
                  return Icon(IconlyBold.star, color: Colors.grey.withOpacity(.4), size: 16.sp);
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
          height: 110,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              CustomWidgets.miniCard(context, user.productCount, 'content', false),
              CustomWidgets.miniCard(context, user.viewCount, 'viewed', false),
              CustomWidgets.miniCard(context, user.premiumCount, 'viewed', true),
            ],
          ),
        ),
        // GestureDetector(
        //     onTap: () {
        //       final List<String> filteredTarifOptions = userProfileController.tarifOptions.where((option) => option != 'type_4').toList();
        //       DialogUtils.showTarifDialog(
        //         context,
        //         tarifOptions: filteredTarifOptions,
        //         initialSelectedTarifs: userProfileController.selectedTarifs.toList(),
        //         onConfirm: (List<String> finalSelections) {
        //           userProfileController.selectedTarifs.assignAll(finalSelections);
        //         },
        //       );
        //     },
        //     child: Container(
        //         margin: EdgeInsets.all(12).copyWith(top: 0),
        //         decoration: BoxDecoration(
        //           color: isDarkMode ? context.blackColor : context.whiteColor,
        //           borderRadius: BorderRadius.circular(15),
        //           boxShadow: [BoxShadow(color: isDarkMode ? context.whiteColor.withOpacity(.5) : context.primaryColor.withOpacity(.3), blurRadius: 5, spreadRadius: 1)],
        //         ),
        //         padding: EdgeInsets.all(15),
        //         child: Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //           children: [
        //             Obx(() => RichText(
        //                   text: TextSpan(
        //                     style: context.textTheme.bodyMedium!.copyWith(
        //                       fontSize: 16.sp,
        //                       color: isDarkMode ? context.whiteColor : context.blackColor, // Temaya göre renk
        //                     ),
        //                     children: <TextSpan>[
        //                       TextSpan(text: "changeTarif".tr + ": ", style: context.textTheme.bodyMedium!.copyWith(color: context.greyColor, fontSize: 14.sp)),
        //                       TextSpan(
        //                         // Seçilen tarifeleri virgülle ayırarak gösterir.
        //                         text: userProfileController.selectedTarifs.join(', ').tr,
        //                         style: TextStyle(
        //                             fontWeight: FontWeight.bold, // Kalın yazı tipi
        //                             fontSize: 14.sp),
        //                       ),
        //                     ],
        //                   ),
        //                 )),
        //             Icon(IconlyLight.arrowDownCircle, color: context.greyColor)
        //           ],
        //         ))),
        // TransparentColorButton(onTap: () => Get.to(() => AddHouseView()), icon: IconlyLight.plus, text: 'addContent'),
      ],
    );
  }
}
