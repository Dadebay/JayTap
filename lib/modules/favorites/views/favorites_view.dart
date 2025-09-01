import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/home/components/properties_widget_view.dart';
import 'package:jaytap/shared/extensions/packages.dart';
import '../controllers/favorites_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    bool themeValue = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 2,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {
          if (tabController.index == 1) {
            controller.fetchFilterDetailsOnTabTap();
            controller.isFilterTabActive.value = true;
          } else {
            controller.isFilterTabActive.value = false;
          }
        });
        return Column(
          children: [
            TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16.sp),
              unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16.sp),
              tabs: [
                Tab(text: "favorites".tr),
                Tab(text: "saved_filter".tr),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  Obx(() {
                    if (controller.isLoading.value) {
                      return CustomWidgets.loader();
                    }
                    if (controller.favoriteProducts.isEmpty) {
                      return CustomWidgets.emptyDataWithLottie(
                        // title: "no_properties_found".tr,
                        // subtitle: "no_fav_found_subtitle".tr,
                        makeBigger: true,
                        lottiePath: IconConstants.favHome,
                      );
                    }
                    return PropertiesWidgetView(
                      isGridView: false,
                      removePadding: false,
                      properties: controller.favoriteProducts,
                      inContentBanners: [],
                      myHouses: false,
                    );
                  }),
                  savedFilters(themeValue),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Obx savedFilters(bool themeValue) {
    return Obx(() {
      if (controller.filterDetails.isEmpty) {
        return CustomWidgets.emptyDataWithLottie(
          // title: "no_filter_found_title".tr,
          // subtitle: "no_filter_found_subtitle".tr,
          makeBigger: true,
          showGif: true,
          lottiePath: IconConstants.searchHouse,
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: controller.filterDetails.length,
        itemBuilder: (context, index) {
          final filter = controller.filterDetails[index];
          return GestureDetector(
            onTap: () => controller.onSavedFilterTap(filter.id),
            child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: ColorConstants.kPrimaryColor2.withOpacity(.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    filter.name ??
                        [filter.villageNameTm, filter.categoryTitleTk]
                            .where((e) => e != null && e.isNotEmpty)
                            .join('-'),
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
                  ),
                  Icon(
                    IconlyLight.arrowRightCircle,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
