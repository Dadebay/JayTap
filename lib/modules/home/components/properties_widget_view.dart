import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:jaytap/modules/home/components/in_content_banner.dart';
import 'package:jaytap/modules/home/components/property_card.dart';
import 'package:jaytap/modules/home/models/banner_model.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';

class PropertiesWidgetView extends StatelessWidget {
  final bool isGridView;
  final bool removePadding;
  final bool myHouses;
  final List<PropertyModel> properties;
  final List<BannerModel> inContentBanners;

  const PropertiesWidgetView({
    super.key,
    this.isGridView = true,
    required this.removePadding,
    required this.properties,
    this.inContentBanners = const [],
    required this.myHouses,
  });

  List<dynamic> _createGroupedList() {
    final modifiableBanners = List<BannerModel>.from(inContentBanners);

    modifiableBanners.sort((a, b) {
      int perPageComparison = a.perPage.compareTo(b.perPage);
      if (perPageComparison != 0) {
        return perPageComparison;
      } else {
        return a.order.compareTo(b.order);
      }
    });

    final List<BannerModel> displayableBanners = modifiableBanners.where((banner) {
      return properties.length >= banner.perPage;
    }).toList();

    List<dynamic> mixedList = List.from(properties);
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
    final groupedList = _createGroupedList();

    return isGridView ? _buildGridView(context, groupedList) : _buildListView(context, groupedList);
  }

  Widget _buildGridView(BuildContext context, List<dynamic> groupedList) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: removePadding == true ? 0 : 16, vertical: 16),
      child: StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: groupedList.map((item) {
          if (item is List<BannerModel>) {
            return StaggeredGridTile.count(
              crossAxisCellCount: 2,
              mainAxisCellCount: 1.25,
              child: InContentBannerCarousel(banners: item),
            );
          } else {
            final property = item as PropertyModel;
            return StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1.25,
              child: PropertyCard(
                property: property,
                isBig: false,
                myHouses: myHouses,
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
      itemCount: groupedList.length,
      padding: EdgeInsets.symmetric(horizontal: removePadding == true ? 0 : 16),
      itemBuilder: (context, index) {
        final item = groupedList[index];

        if (item is List<BannerModel>) {
          return InContentBannerCarousel(banners: item, isBig: true);
        } else {
          final property = item as PropertyModel;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SizedBox(
              height: 380,
              child: PropertyCard(
                property: property,
                isBig: true,
                myHouses: myHouses,
              ),
            ),
          );
        }
      },
    );
  }
}
