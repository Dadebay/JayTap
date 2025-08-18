import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/photo_view_screen.dart';

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
    if (_imageUrls.isEmpty) {
      return Container(
          height: 261,
          width: double.infinity,
          color: Colors.grey[200],
          child: Icon(Icons.image_not_supported,
              size: 100, color: Colors.grey[400]));
    }

    return Stack(
      children: [
        SizedBox(
          height: 261,
          width: double.infinity,
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
          ),
        ),
        Positioned(
          top: 10,
          left: 16,
          child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  IconlyLight.arrowLeft,
                  size: 30,
                  color: Colors.black,
                ),
                onPressed: () {
                  Get.back();
                },
                padding: const EdgeInsets.all(8),
              )),
        ),
        Positioned(
          top: 10,
          right: 16,
          child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  IconlyBold.heart,
                  size: 30,
                  color: Color.fromARGB(255, 230, 30, 77),
                ),
                onPressed: () {
                  // TODO: Implement favorite functionality
                },
                padding: const EdgeInsets.all(8),
              )),
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
                color:
                    const Color.fromARGB(255, 34, 34, 34).withOpacity(0.7),
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
    );
  }
}