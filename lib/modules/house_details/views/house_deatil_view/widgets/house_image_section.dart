import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/favorites/views/fav_button.dart';
import 'package:jaytap/modules/house_details/controllers/house_details_controller.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/photo_view_screen.dart';
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
    print(_imageUrls.length);

    return Container(
      height: Get.size.height / 3,
      padding: EdgeInsets.only(top: 50),
      child: Stack(
        children: [
          if (_imageUrls.isEmpty)
            Positioned.fill(
                child: Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.image_not_supported,
                        size: 100, color: Colors.grey[400])))
          else
            Positioned.fill(
              child: PageView.builder(
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
                      Get.to(
                          () => PhotoViewScreen(imageUrl: _imageUrls[index]));
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
              ),
            ),
          Positioned(
            top: 10,
            left: 16,
            child: ElevatedButton(
              child: const Icon(
                IconlyLight.arrowLeft,
                color: Colors.black,
              ),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero, fixedSize: Size(10, 60)),
              onPressed: () {
                print("i tapped");
                Navigator.of(context).pop();
              },
            ),
          ),
          Positioned(
            top: 10,
            right: 16,
            child: Row(children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () => _showZalobaDialog(context, controller),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              FavButton(itemId: widget.house.id)
            ]),
          ),
          if (_imageUrls.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_imageUrls.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          Positioned(
              bottom: 10,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 34, 34, 34).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '${_currentPage + 1}/${_imageUrls.length}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              )),
        ],
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
                // Hazır nedenler için kaydırılabilir liste
                SizedBox(
                  height: Get.height * 0.3, // Yüksekliği ayarla
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount:
                        controller.zalobaReasons.length + 1, // +1 "Diğer" için
                    itemBuilder: (context, index) {
                      if (index < controller.zalobaReasons.length) {
                        final reason = controller.zalobaReasons[index];
                        return RadioListTile<int>(
                          title: Text(reason.titleTm), // Veya dil seçimine göre
                          value: reason.id,
                          groupValue: controller.selectedZalobaId.value,
                          onChanged: controller.selectZaloba,
                        );
                      } else {
                        // "Diğer" seçeneği
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

                // "Diğer" seçilince görünecek metin alanı
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
        // Onay ve İptal Butonları
        confirm: Obx(() => ElevatedButton(
              onPressed: () {
                if (controller.selectedZalobaId.value == null) {
                  CustomWidgets.showSnackBar(
                      "Error", "Select Zalob", Colors.red);
                } else {
                  controller.submitZaloba(houseId: widget.house.id);
                  // int.parse(controller.selectedZalobaId.value.toString())
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
