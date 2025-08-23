// lib/modules/home/components/in_content_banner_carousel.dart

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

class InContentBannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;
  final bool isBig;

  const InContentBannerCarousel({
    super.key,
    required this.banners,
    this.isBig = false,
  });

  @override
  State<InContentBannerCarousel> createState() => _InContentBannerCarouselState();
}

class _InContentBannerCarouselState extends State<InContentBannerCarousel> {
  final HomeController _homeController = Get.find<HomeController>();
  final searchController = Get.find<SearchControllerMine>();

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Hata durumunda bir snackbar gösterebilirsiniz.
      Get.snackbar("Hata", "URL açılamadı: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Eğer banner listesi boşsa hiçbir şey gösterme
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      // ListView ve GridView arasındaki boşlukları yönetmek için margin
      margin: EdgeInsets.only(bottom: widget.isBig ? 20 : 16),
      child: CarouselSlider.builder(
        itemCount: widget.banners.length,
        itemBuilder: (context, index, realIndex) {
          final banner = widget.banners[index];
          return GestureDetector(
            onTap: () {
              if (banner.link != null && banner.link!.isNotEmpty) {
                _launchURL(banner.link!);
              } else if (banner.description != null && banner.description!.isNotEmpty) {
                Get.to(() => BannersProfile(banner: banner));
              } else if (banner.productID != null && banner.productID!.isNotEmpty && banner.productID.toString() != '0') {
                Get.to(() => HouseDetailsView(houseID: int.parse(banner.productID!), myHouses: false));
              } else if (banner.catID != null) {
                searchController.fetchProperties(categoryId: int.parse(banner.catID.toString()));
                _homeController.changePage(1); // Ana sayfadaki tab'ı değiştirir
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomWidgets.imageWidget(banner.img, false),
            ),
          );
        },
        options: CarouselOptions(
          height: widget.isBig ? 380 : 200,
          autoPlay: widget.banners.length > 1,
          aspectRatio: 16 / 9,
          viewportFraction: 1.0,
          onPageChanged: (index, reason) {
            setState(() {});
          },
        ),
      ),
    );
  }
}
