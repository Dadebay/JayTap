import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/models/banner_model.dart';
import 'package:jaytap/shared/widgets/custom_app_bar.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:kartal/kartal.dart';

class BannersProfile extends StatelessWidget {
  const BannersProfile({required this.banner, super.key});
  final BannerModel banner;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'banner', showBackButton: true),
      body: ListView(
        children: [
          Container(
            padding: context.padding.normal,
            height: Get.size.height / 3.5,
            child: CustomWidgets.imageWidget(banner.img, false, false),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              banner.description!,
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
