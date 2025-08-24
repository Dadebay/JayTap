import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
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
        color: Colors.grey.shade200,
        child: Center(
          child: Icon(
            Icons.house_rounded,
            size: 120,
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
            Get.to(() => PhotoViewScreen(imageUrl: _imageUrls[index]));
          },
          child: Image.network(
            _imageUrls[index],
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
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
              icon: const Icon(IconlyLight.arrowLeft, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Row(
            children: [
              _buildFrostedCircleButton(
                child: IconButton(
                  icon: const Icon(Icons.info_outline,
                      color: Color.fromARGB(255, 32, 32, 32)),
                  onPressed: () => _showZalobaDialog(context, controller),
                ),
              ),
              const SizedBox(width: 8),
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
            color: Colors.white.withOpacity(0.8),
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
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                                  ? Colors.white
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
                  color: Colors.white.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
                if (widget.house.vr != null && widget.house.vr!.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.threesixty, color: Colors.blue),
                      onPressed: () {},
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showZalobaDialog(
      BuildContext context, HouseDetailsController controller) {
    controller.fetchZalobaReasons();
    Get.defaultDialog(
        title: "Şikayet Et",
        titlePadding: EdgeInsets.all(20),
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        content: Obx(() {
          if (controller.isLoadingZaloba.value) {
            return SizedBox(
                height: 100, child: Center(child: CircularProgressIndicator()));
          }
          return SizedBox(
            width: Get.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: Get.height * 0.3,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount:
                        controller.zalobaReasons.length + 1, // +1 "Diğer" için
                    itemBuilder: (context, index) {
                      if (index < controller.zalobaReasons.length) {
                        final reason = controller.zalobaReasons[index];
                        return RadioListTile<int>(
                          title: Text(reason.titleTm),
                          value: reason.id,
                          groupValue: controller.selectedZalobaId.value,
                          onChanged: controller.selectZaloba,
                        );
                      } else {
                        return RadioListTile<int>(
                          title: Text("Başga bir zalob"),
                          value: controller.otherOptionId,
                          groupValue: controller.selectedZalobaId.value,
                          onChanged: controller.selectZaloba,
                        );
                      }
                    },
                  ),
                ),
                if (controller.selectedZalobaId.value ==
                    controller.otherOptionId)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: TextField(
                      controller: controller.customZalobaController,
                      decoration: InputDecoration(
                        labelText: "Şikayetinizi yazın",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ),
              ],
            ),
          );
        }),
        confirm: Obx(() => ElevatedButton(
              onPressed: () {
                if (controller.selectedZalobaId.value == null) {
                  CustomWidgets.showSnackBar(
                      "Error", "Select Zalob", Colors.red);
                } else {
                  controller.submitZaloba(houseId: widget.house.id);
                }
              },
              child: controller.isSubmittingZaloba.value
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text("Gönder"),
            )),
        cancel: TextButton(
          onPressed: () => Get.back(),
          child: Text("İptal"),
        ));
  }
}
