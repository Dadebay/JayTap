// lib/modules/home/components/banner_carousel.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/home/models/banner_model.dart';
import 'package:jaytap/modules/home/views/pages/banners_profile_view.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/house_details_view.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, required this.bannersList});
  final List<BannerModel> bannersList;
  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentIndex = 0;
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  final HomeController _homeController = Get.find<HomeController>();
  final searchController = Get.find<SearchControllerMine>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: widget.bannersList.length,
            itemBuilder: (context, index, realIndex) {
              final banner = widget.bannersList[index];
              return GestureDetector(
                onTap: () {
                  if (banner.link!.isNotEmpty) {
                    _launchURL(banner.link!);
                  } else if (banner.description!.isNotEmpty) {
                    Get.to(() => BannersProfile(banner: banner));
                  } else if (banner.productID!.isNotEmpty && banner.productID.toString() != '0') {
                    Get.to(() => HouseDetailsView(houseID: int.parse(banner.productID!), myHouses: false));
                  } else {
                    searchController.fetchProperties(categoryId: int.parse(banner.catID.toString()));
                    _homeController.changePage(1);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 16, right: 16, top: 40),
                  child: CustomWidgets.imageWidget(banner.img, false, false),
                ),
              );
            },
            options: CarouselOptions(
              height: 250,
              autoPlay: widget.bannersList.length > 1, // Only autoplay if more than one banner
              aspectRatio: 16 / 9,
              viewportFraction: 1.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
          Positioned(
            bottom: 0.0,
            right: 0.0,
            left: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.bannersList.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.white).withOpacity(_currentIndex == entry.key ? 0.9 : 0.4),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
