import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/modules/home/components/in_content_banner.dart';
import 'package:jaytap/modules/home/components/property_card.dart';
import 'package:jaytap/modules/home/models/banner_model.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/home/service/home_service.dart';
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
  final HomeService _homeService = HomeService();
  var _propertyList = <PropertyModel>[].obs;
  var _isLoadingProperties = true.obs;

  @override
  void initState() {
    super.initState();
    if (widget.realtorId != null) {
      _fetchPropertiesForRealtor();
    } else {
      _propertyList.assignAll(widget.properties);
      _isLoadingProperties(false);
    }
  }

  Future<void> _fetchPropertiesForRealtor() async {
    try {
      _isLoadingProperties(true);
      final fetchedProperties =
          await _homeService.fetchUserProducts(widget.realtorId!);
      _propertyList.assignAll(fetchedProperties);
    } finally {
      _isLoadingProperties(false);
    }
  }

  List<dynamic> _createGroupedList() {
    final modifiableBanners = List<BannerModel>.from(widget.inContentBanners);

    modifiableBanners.sort((a, b) {
      int perPageComparison = a.perPage.compareTo(b.perPage);
      if (perPageComparison != 0) {
        return perPageComparison;
      } else {
        return a.order.compareTo(b.order);
      }
    });

    final List<BannerModel> displayableBanners =
        modifiableBanners.where((banner) {
      return _propertyList.length >= banner.perPage;
    }).toList();

    List<dynamic> mixedList = List.from(_propertyList);
    int bannersInserted = 0;

    for (var banner in displayableBanners) {
      int insertionIndex = banner.perPage + bannersInserted;

      if (insertionIndex <= mixedList.length) {
        mixedList.insert(insertionIndex, banner);
        bannersInserted++;
      } else {
        mixedList.add(banner);
      }
    }
    if (mixedList.isEmpty) return [];
    List<dynamic> groupedList = [];
    List<BannerModel> currentBannerGroup = [];
    for (final item in mixedList) {
      if (item is BannerModel) {
        currentBannerGroup.add(item);
      } else {
        if (currentBannerGroup.isNotEmpty) {
          groupedList.add(List<BannerModel>.from(currentBannerGroup));
          currentBannerGroup.clear();
        }
        groupedList.add(item);
      }
    }
    if (currentBannerGroup.isNotEmpty) {
      groupedList.add(List<BannerModel>.from(currentBannerGroup));
    }
    return groupedList;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
        mainAxisSpacing: 8,
        crossAxisSpacing: 14,
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
          // SizedBox yüksekliğini kaldırdık çünkü Card widget'ı kendi boyutunu yönetecek.
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
