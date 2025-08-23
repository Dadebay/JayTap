import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/core/constants/string_constants.dart';
import 'package:jaytap/modules/home/components/banner_carousel.dart';
import 'package:jaytap/modules/home/components/category_widget_view.dart';
import 'package:jaytap/modules/home/components/properties_widget_view.dart';
import 'package:jaytap/modules/home/components/realtor_widget_view.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/home/views/pages/notifications_view.dart';
import 'package:jaytap/modules/home/views/pages/show_all_realtors.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController _homeController = Get.find<HomeController>();
  @override
  void initState() {
    super.initState();
    _homeController.fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _customAppBar(context),
        CategoryWidgetView(),
        CustomWidgets.listViewTextWidget(
            text: 'realtor',
            removeIcon: false,
            ontap: () {
              Get.to(() => ShowAllRealtors());
            }),
        RealtorListView(),
        Obx(() {
          return _homeController.isLoadingBanners.value ||
                  _homeController.topBanners.isEmpty
              ? SizedBox.shrink()
              : BannerCarousel(bannersList: _homeController.topBanners);
        }),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20).copyWith(bottom: 0),
          child: CustomWidgets.listViewTextWidget(
              text: "nearly_houses", removeIcon: true, ontap: () {}),
        ),
        Obx(() {
          if (_homeController.isLoadingProperties.value) {
            return CustomWidgets.loader();
          }
          return Padding(
            padding: const EdgeInsets.all(8.0).copyWith(top: 0),
            child: PropertiesWidgetView(
              removePadding: true,
              properties: _homeController.propertyList,
              inContentBanners: _homeController.inContentBanners,
              myHouses: false,
            ),
          );
        }),
        const SizedBox(height: 240),
      ],
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
                      color: Color(0xff43A0D9),
                      fontWeight: FontWeight.w500,
                      fontSize: 20)),
            ],
          ),
          GestureDetector(
            onTap: () {
              Get.to(() => NotificationsView());
            },
            child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: context.greyColor.withOpacity(.3)),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Icon(IconlyLight.notification, size: 22))),
          )
        ],
      ),
    );
  }
}
