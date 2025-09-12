import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/core/constants/string_constants.dart';
import 'package:jaytap/modules/home/components/banner_carousel.dart';
import 'package:jaytap/modules/home/components/category_widget_view.dart';
import 'package:jaytap/modules/home/components/properties_widget_view.dart';
import 'package:jaytap/modules/home/components/realtor_widget_view.dart';
import 'package:jaytap/modules/home/views/pages/notifications_view.dart';
import 'package:jaytap/modules/home/views/pages/show_all_realtors.dart';
import 'package:jaytap/shared/extensions/packages.dart';
import 'package:jaytap/modules/home/controllers/notification_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController _homeController = Get.find<HomeController>();
  final NotificationController _notificationController =
      Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    _homeController.fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _homeController.fetchAllData();
      },
      color: Theme.of(context).colorScheme.onPrimary,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: ListView(
        children: [
          _customAppBar(context),
          CategoryWidgetView(),
          CustomWidgets.listViewTextWidget(
            text: 'realtor'.tr,
            removeIcon: false,
            ontap: () {
              Get.to(() => ShowAllRealtors());
            },
          ),
          RealtorListView(),
          Obx(() {
            return _homeController.isLoadingBanners.value ||
                    _homeController.topBanners.isEmpty
                ? const SizedBox.shrink()
                : BannerCarousel(bannersList: _homeController.topBanners);
          }),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10).copyWith(bottom: 0),
            child: CustomWidgets.listViewTextWidget(
                text: "nearly_houses".tr, removeIcon: true, ontap: () {}),
          ),
          Obx(() {
            if (_homeController.isLoadingProperties.value) {
              return CustomWidgets.loader();
            }
            return Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
              child: PropertiesWidgetView(
                removePadding: true,
                properties: _homeController.propertyList,
                inContentBanners: _homeController.inContentBanners,
                myHouses: false,
              ),
            );
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
              Text(StringConstants.appName,
                  style: context.textTheme.bodyMedium!.copyWith(
                      color: const Color(0xff43A0D9),
                      fontWeight: FontWeight.w500,
                      fontSize: 20)),
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
                      border:
                          Border.all(color: context.greyColor.withOpacity(.3)),
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
                        _notificationController.notificationCount.value
                            .toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
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
