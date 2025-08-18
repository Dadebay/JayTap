import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/favorites/views/fav_button.dart';
import 'package:jaytap/modules/home/components/properties_widget_view.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:kartal/kartal.dart';

import '../controllers/favorites_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    bool themeValue = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: context.primaryColor,
            child: TabBar(
              indicatorColor: Colors.white,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, color: context.whiteColor, fontSize: 18.sp),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, color: Colors.white70, fontSize: 18.sp),
              tabs: [
                Tab(text: "favorites".tr),
                Tab(text: "saved_filter".tr),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // FutureBuilder yerine Obx kullanın
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.favoriteProducts.isEmpty) {
                    return Center(child: Text("favori_urun_yok".tr));
                  }
                  return PropertiesWidgetView(
                    isGridView: false,
                    removePadding: false,
                    properties: controller.favoriteProducts,
                    inContentBanners: [],
                  );
                }),
                savedFilters(themeValue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container productCard(bool themeValue, BuildContext context, int index) {
    return Container(
      height: Get.size.height / 2.2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: themeValue ? context.blackColor : Colors.white,
        borderRadius: context.border.normalBorderRadius,
        boxShadow: [BoxShadow(color: themeValue ? Colors.grey.shade600 : Colors.grey.shade200, spreadRadius: 3, blurRadius: 3)],
        border: Border.all(color: themeValue ? context.whiteColor.withOpacity(.4) : context.greyColor.withOpacity(.6)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset('assets/images/house${index + 1}.png', width: Get.size.width, fit: BoxFit.cover),
                    ),
                    Positioned(top: 10, right: 10, child: FavButton(itemId: index + 1)),
                    Positioned(
                        bottom: 10,
                        right: 0,
                        left: 0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [dot(context), dot(context), dot(context), dot(context)],
                        )),
                  ],
                )),
            Expanded(
              flex: 3,
              child: Placeholder(),
            ),
          ],
        ),
      ),
    );
  }

  Container dot(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      margin: EdgeInsets.only(left: 8),
      decoration: BoxDecoration(color: context.whiteColor, border: Border.all(color: context.primaryColor), shape: BoxShape.circle),
    );
  }

  ListView savedFilters(bool themeValue) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: controller.savedFilters.length,
      itemBuilder: (context, index) {
        final filter = controller.savedFilters[index];
        return Dismissible(
          key: Key(filter.name),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {},
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 0,
            color: themeValue ? context.whiteColor.withOpacity(.1) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: context.border.lowBorderRadius, side: BorderSide(color: themeValue ? context.whiteColor.withOpacity(.4) : context.greyColor.withOpacity(.6))),
            child: ListTile(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(IconlyLight.filter2, size: 20, color: themeValue ? context.whiteColor : context.blackColor),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        filter.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Icon(IconlyLight.arrowRightCircle, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
