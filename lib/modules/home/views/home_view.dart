import 'package:get/get.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/core/constants/string_constants.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';

import 'package:jaytap/modules/auth/views/login_view.dart';
import 'package:jaytap/modules/home/components/banner_carousel.dart';
import 'package:jaytap/modules/home/components/category_widget_view.dart';
import 'package:jaytap/modules/home/components/properties_widget_view.dart';
import 'package:jaytap/modules/home/components/realtor_widget_view.dart';
import 'package:jaytap/modules/home/views/pages/notifications_view.dart';
import 'package:jaytap/modules/home/views/pages/show_all_realtors.dart';
import 'package:jaytap/shared/extensions/packages.dart';
import 'package:jaytap/modules/home/controllers/notification_controller.dart';
import 'package:jaytap/modules/house_details/views/add_house_view/add_house_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController _homeController = Get.find<HomeController>();
  final NotificationController _notificationController = Get.put(NotificationController());
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  Widget shimmerBox({double height = 100, double width = double.infinity, double radius = 8}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _homeController.fetchAllData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    print("🔄 onRefresh started");
    await _homeController.fetchAllData();
    print("✅ onRefresh completed");
    _refreshController.refreshCompleted();

    // Reset footer state to allow loading more after refresh
    if (_homeController.hasMoreProperties.value) {
      _refreshController.resetNoData();
      print("🔄 Reset footer - ready for onLoading");
    }
  }

  void _onLoading() async {
    print("⬆️ onLoading started");
    await _homeController.loadMoreProperties();
    if (_homeController.hasMoreProperties.value) {
      print("✅ Load complete - has more data");
      _refreshController.loadComplete();
    } else {
      print("🛑 No more data");
      _refreshController.loadNoData();
    }
  }

  Widget createPostButton() {
    return GestureDetector(
      onTap: () {
        final _auth = AuthStorage();

        if (_auth.token != null) {
          Get.to(() => AddHouseView());
        } else {
          Get.to(() => LoginView());
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xffE2F3FC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: ColorConstants.kPrimaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "addContent".tr,
                style: TextStyle(
                  color: ColorConstants.kPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus? mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text('pull_up_load'.tr);
          } else if (mode == LoadStatus.loading) {
            body = CustomWidgets.loader();
          } else if (mode == LoadStatus.failed) {
            body = Text('load_failed'.tr);
          } else if (mode == LoadStatus.canLoading) {
            body = Text('release_to_load_more'.tr);
          } else {
            body = Text('no_more_data'.tr);
          }
          return SizedBox(height: 55.0, child: Center(child: body));
        },
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _customAppBar(context)),
          SliverToBoxAdapter(child: CategoryWidgetView()),
          SliverToBoxAdapter(child: createPostButton()),
          SliverToBoxAdapter(
            child: CustomWidgets.listViewTextWidget(
              text: 'realtor'.tr,
              removeIcon: false,
              ontap: () {
                Get.to(() => ShowAllRealtors());
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(() {
              if (_homeController.isLoadingRealtors.value || _homeController.realtorList.isEmpty) {
                return SizedBox(
                  height: 120,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => Column(
                      children: [
                        shimmerBox(height: 80, width: 80, radius: 40),
                        const SizedBox(height: 8),
                        shimmerBox(height: 12, width: 60, radius: 6),
                      ],
                    ),
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: 3,
                  ),
                );
              } else {
                return RealtorListView();
              }
            }),
          ),
          SliverToBoxAdapter(
            child: Obx(() {
              if (_homeController.isLoadingBanners.value || _homeController.topBanners.isEmpty) {
                return SizedBox(
                  height: 160,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => shimmerBox(height: 160, width: 300, radius: 12),
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemCount: 3,
                  ),
                );
              } else {
                return BannerCarousel(bannersList: _homeController.topBanners);
              }
            }),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10).copyWith(bottom: 0),
              child: CustomWidgets.listViewTextWidget(text: "nearly_houses".tr, removeIcon: true, ontap: () {}),
            ),
          ),
          Obx(() {
            if (_homeController.isLoadingProperties.value) {
              return SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => shimmerBox(height: 180, radius: 10),
                    childCount: 6,
                  ),
                ),
              );
            } else {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
                  child: Obx(() {
                    // By accessing propertyList.length, we register it as a dependency for this Obx.
                    final _ = _homeController.propertyList.length;
                    return PropertiesWidgetView(
                      removePadding: true,
                      properties: _homeController.propertyList,
                      inContentBanners: _homeController.inContentBanners,
                      myHouses: false,
                    );
                  }),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _customAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 5),
                child: Image.asset(IconConstants.appLogoWhtie, width: 40),
              ),
              Text(StringConstants.appName, style: context.textTheme.bodyMedium!.copyWith(color: const Color(0xff43A0D9), fontWeight: FontWeight.w500, fontSize: 20)),
            ],
          ),
          Obx(
            () => Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () {
                    _notificationController.reset();
                    Get.to(() => const NotificationsView());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.greyColor.withOpacity(.3)),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                        child: Icon(
                      Icons.notifications_none,
                      size: 22,
                      color: Colors.grey,
                    )),
                  ),
                ),
                if (_notificationController.notificationCount.value > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _notificationController.notificationCount.value.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
