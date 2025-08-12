import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:kartal/kartal.dart';

class CategoryWidgetView extends StatelessWidget {
  const CategoryWidgetView({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return Container(
          height: Get.size.height / 2.6,
          alignment: Alignment.center,
          child: CustomWidgets.loader(),
        );
      }

      if (controller.categoryList.length < 3) {
        return SizedBox(height: Get.size.height / 2.6);
      }

      final arendaCategory = controller.categoryList.firstWhere((c) => c.id == 1);
      final satlykCategory = controller.categoryList.firstWhere((c) => c.id == 2);
      final commercialCategory = controller.categoryList.firstWhere((c) => c.id == 3);

      return Container(
        height: Get.size.height / 2.6,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CategoryCard(
                      categoryId: satlykCategory.id,
                      imageUrl: satlykCategory.img,
                      title: satlykCategory.getLocalizedTitle(context),
                      large: false,
                      location: 1,
                    ),
                  ),
                  Expanded(
                    child: CategoryCard(
                      categoryId: arendaCategory.id,
                      imageUrl: arendaCategory.img,
                      title: arendaCategory.getLocalizedTitle(context),
                      large: false,
                      location: 2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: CategoryCard(
                categoryId: commercialCategory.id,
                imageUrl: commercialCategory.img,
                title: commercialCategory.getLocalizedTitle(context),
                large: true,
                location: 3,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class CategoryCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String? subtitle;
  final bool large;
  final int categoryId;
  final int location;

  CategoryCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.categoryId,
    this.subtitle,
    required this.large,
    required this.location,
  });
  final HomeController _homeController = Get.find<HomeController>();
  final SearchControllerMine searchController = Get.find<SearchControllerMine>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        print(categoryId);
        searchController.fetchProperties(categoryId: categoryId);
        _homeController.changePage(1);
      },
      child: Container(
        height: Get.size.height,
        width: Get.size.width,
        margin: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: location == 2 ? 40 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: location == 2 ? 25 : 45),
                    decoration: BoxDecoration(
                      color: isDarkMode ? context.whiteColor.withOpacity(.3) : context.greyColor.withOpacity(.1),
                      borderRadius: context.border.normalBorderRadius,
                    ),
                  ),
                  Positioned(
                      top: 0.0,
                      right: large ? 15.0 : 5,
                      left: large ? 15.0 : 5,
                      bottom: location == 2 ? 10 : 0,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(image: DecorationImage(image: imageProvider)),
                        ),
                        placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) {
                          return Icon(IconlyLight.infoSquare);
                        },
                      )),
                ],
              ),
            ),
            Padding(
              padding: context.padding.onlyTopLow,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                  shadows: [Shadow(blurRadius: 2, color: Colors.white)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
