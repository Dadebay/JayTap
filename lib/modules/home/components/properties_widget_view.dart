import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/modules/home/components/in_content_banner.dart';
import 'package:jaytap/modules/home/components/property_card.dart';
import 'package:jaytap/modules/home/models/banner_model.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

class PropertiesWidgetView extends StatefulWidget {
  final bool isGridView;
  final bool removePadding;
  final bool myHouses;
  final List<PropertyModel> properties;
  final List<BannerModel> inContentBanners;
  final int? realtorId;

  const PropertiesWidgetView({
    super.key,
    this.isGridView = true,
    required this.removePadding,
    this.properties = const [],
    this.inContentBanners = const [],
    required this.myHouses,
    this.realtorId,
  });

  @override
  State<PropertiesWidgetView> createState() => _PropertiesWidgetViewState();
}

class _PropertiesWidgetViewState extends State<PropertiesWidgetView> {
  RxList<PropertyModel> _propertyList = <PropertyModel>[].obs;
  RxBool _isLoadingProperties = true.obs;

  @override
  void initState() {
    super.initState();
    _propertyList.assignAll(widget.properties);
    _isLoadingProperties(false);
  }

  @override
  void didUpdateWidget(PropertiesWidgetView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.properties != oldWidget.properties) {
      _propertyList.assignAll(widget.properties);
    }
  }

  List<dynamic> _createGroupedList() {
    // Eğer hiç mülk yoksa, boş bir liste döndür.
    if (_propertyList.isEmpty) return [];

    // 1. Adım: Sadece gösterilmesi gereken banner'ları filtrele.
    // Bir banner'ın gösterilmesi için toplam mülk sayısı, banner'ın 'perPage' değerinden fazla veya eşit olmalı.
    final displayableBanners = widget.inContentBanners.where((banner) {
      return _propertyList.length >= banner.perPage;
    }).toList();

    // Gösterilecek banner yoksa, sadece mülk listesini döndür.
    if (displayableBanners.isEmpty) {
      return _propertyList;
    }

    // 2. Adım: Banner'ları, hangi mülk sayısından sonra ekleneceklerine göre grupla.
    // Map yapısı kullanıyoruz: Anahtar (key) -> mülk sayısı, Değer (value) -> o noktada gösterilecek banner listesi.
    final Map<int, List<BannerModel>> bannerMap = {};
    for (var banner in displayableBanners) {
      if (banner.perPage > 0) {
        bannerMap.putIfAbsent(banner.perPage, () => []).add(banner);
      }
    }

    // Aynı pozisyonda birden fazla banner varsa, onları kendi 'order' (sıra) değerlerine göre sırala.
    bannerMap.forEach((key, banners) {
      banners.sort((a, b) => a.order.compareTo(b.order));
    });

    // 3. Adım: Mülkleri ve banner'ları birleştirerek nihai listeyi oluştur.
    List<dynamic> groupedList = [];
    for (int i = 0; i < _propertyList.length; i++) {
      // Önce mülkü listeye ekle.
      groupedList.add(_propertyList[i]);

      // Bu mülkten sonra bir banner grubu eklenmesi gerekip gerekmediğini kontrol et.
      // 'i + 1' o ana kadar eklenen toplam mülk sayısını verir.
      int propertyCount = i + 1;
      if (bannerMap.containsKey(propertyCount)) {
        // Eğer bu mülk sayısına karşılık gelen bir banner grubu varsa, onu listeye ekle.
        groupedList.add(bannerMap[propertyCount]!);
      }
    }

    return groupedList;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      print(
          '0------------Building PropertiesWidgetView with ${_propertyList.length} properties');
      if (_isLoadingProperties.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_propertyList.isEmpty) {
        return CustomWidgets.emptyDataWithLottie(
          title: "no_properties_found".tr,
          subtitle: "no_properties_found_text".tr,
          lottiePath: IconConstants.emptyHouses,
        );
      }
      final groupedList = _createGroupedList();

      return widget.isGridView
          ? _buildGridView(context, groupedList)
          : _buildListView(context, groupedList);
    });
  }

  Widget _buildGridView(BuildContext context, List<dynamic> groupedList) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: widget.removePadding == true ? 0 : 12, vertical: 12),
      child: StaggeredGrid.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 8,
        children: groupedList.map((item) {
          if (item is List<BannerModel>) {
            return StaggeredGridTile.count(
              crossAxisCellCount: crossAxisCount,
              mainAxisCellCount: 1,
              child: InContentBannerCarousel(banners: item),
            );
          } else {
            final property = item as PropertyModel;
            return StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: crossAxisCount == 3 ? 1.3 : 1.5,
              child: PropertyCard(
                property: property,
                isBig: false,
                myHouses: widget.myHouses,
              ),
            );
          }
        }).toList(),
      ),
    );
  }

  Widget _buildListView(BuildContext context, List<dynamic> groupedList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: groupedList.length,
      padding: EdgeInsets.symmetric(
          horizontal: widget.removePadding == true ? 0 : 16, vertical: 8),
      itemBuilder: (context, index) {
        final item = groupedList[index];

        if (item is List<BannerModel>) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: InContentBannerCarousel(banners: item, isBig: true),
          );
        } else {
          final property = item as PropertyModel;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PropertyCard(
              property: property,
              isBig: true,
              myHouses: widget.myHouses,
            ),
          );
        }
      },
    );
  }
}
