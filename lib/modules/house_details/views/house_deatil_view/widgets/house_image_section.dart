import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/constants/icon_constants.dart';
import 'package:jaytap/modules/house_details/controllers/house_details_controller.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/photo_view_screen.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/favbuton.dart';
import '../../../../../shared/widgets/widgets.dart';

class HouseImageSection extends StatefulWidget {
  const HouseImageSection({Key? key, required this.house}) : super(key: key);
  final PropertyModel house;

  @override
  State<HouseImageSection> createState() => _HouseImageSectionState();
}

class _HouseImageSectionState extends State<HouseImageSection> {
  int _currentPage = 0;
  late final PageController _pageController;
  late final List<String> _imageUrls;
  final HouseDetailsController controller = Get.put(HouseDetailsController());

  @override
  void initState() {
    super.initState();
    _imageUrls = _getImageUrls();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> _getImageUrls() {
    final List<String> urls = [];
    final dynamic imgUrlAnother = widget.house.imgUrlAnother;
    if (imgUrlAnother != null) {
      if (imgUrlAnother is List && imgUrlAnother.isNotEmpty) {
        urls.addAll(imgUrlAnother.map((item) => item.toString()));
      } else if (imgUrlAnother is String && imgUrlAnother.isNotEmpty) {
        urls.add(imgUrlAnother);
      }
    }

    final String? mainImg = widget.house.img;
    if (urls.isEmpty && mainImg != null && mainImg.isNotEmpty) {
      urls.add(mainImg);
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.53,
      child: Stack(
        children: [
          _buildPageView(),
          _buildTopButtons(context),
          if (_imageUrls.length > 1) _buildBottomThumbnails(),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    if (_imageUrls.isEmpty) {
      return Container(
        width: Get.size.width,
        height: 400,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Container(
          margin: EdgeInsets.only(left: 10, right: 10, top: 30),
          child: Center(
            child: Image.asset(IconConstants.empty,
                height: 250, fit: BoxFit.contain, color: Colors.grey),
          ),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: _imageUrls.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Get.to(() =>
                PhotoViewScreen(imageUrls: _imageUrls, initialIndex: index));
          },
          child: Image.network(
            _imageUrls[index],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return CustomWidgets.loader();
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error);
            },
          ),
        );
      },
    );
  }

  Widget _buildTopButtons(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPadding + 10,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFrostedCircleButton(
            child: IconButton(
              icon: Icon(IconlyLight.arrowLeftCircle,
                  color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Row(
            children: [
              _buildFrostedCircleButton(
                child: FavButtonDetail(itemId: widget.house.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrostedCircleButton({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildBottomThumbnails() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageUrls.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          width: 54,
                          height: 54,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _currentPage == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _imageUrls[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
                if (widget.house.vr != null && widget.house.vr!.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      // Get.to(() => PanoramaViewPage(vrData: widget.house.vr!));
                    },
                    child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.4)
                                  : Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Theme.of(context).brightness == Brightness.dark
                            ? ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  'assets/icons/360degree.png',
                                  width: 30,
                                  height: 30,
                                ),
                              )
                            : Image.asset(
                                'assets/icons/360degree.png',
                                width: 30,
                                height: 30,
                              )),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
