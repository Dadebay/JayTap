import 'package:jaytap/shared/extensions/packages.dart';
import 'package:kartal/kartal.dart';

class CategoryWidgetView extends StatelessWidget {
  CategoryWidgetView({super.key});
  final SearchControllerMine searchController = Get.find<SearchControllerMine>();
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return Container(
          height: Get.size.height / 2.6,
          alignment: Alignment.center,
          child: CustomWidgets.loader(),
        );
      }

      if (controller.displaySubCategories.length < 3) {
        return SizedBox(height: Get.size.height / 2.6);
      }

      final subCategory1 = controller.displaySubCategories[0];
      final subCategory2 = controller.displaySubCategories[1];
      final subCategory3 = controller.displaySubCategories[2];

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
                      categoryId: subCategory1.parentCategoryId,
                      imageUrl: subCategory1.subCategory.imgUrl,
                      title: subCategory1.subCategory.getLocalizedTitle(context),
                      large: false,
                      location: 1,
                      onTAP: () {
                        searchController.fetchJayByID(categoryID: 1);

                        controller.changePage(1);
                      },
                    ),
                  ),
                  Expanded(
                    child: CategoryCard(
                      categoryId: subCategory3.parentCategoryId,
                      imageUrl: subCategory3.subCategory.imgUrl,
                      title: subCategory3.subCategory.getLocalizedTitle(context),
                      large: false,
                      location: 2,
                      onTAP: () {
                        searchController.fetchJayByID(categoryID: 2);

                        controller.changePage(1);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: CategoryCard(
                categoryId: subCategory2.parentCategoryId,
                imageUrl: subCategory2.subCategory.imgUrl,
                title: subCategory2.subCategory.getLocalizedTitle(context),
                large: true,
                location: 3,
                onTAP: () {
                  searchController.fetchTajircilik();
                  controller.changePage(1);
                },
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
  final VoidCallback onTAP;

  CategoryCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.onTAP,
    required this.categoryId,
    this.subtitle,
    required this.large,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        onTAP();
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
