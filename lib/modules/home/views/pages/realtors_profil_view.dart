import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/models/realtor_model.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:kartal/kartal.dart';
import 'package:url_launcher/url_launcher.dart';

class RealtorsProfileView extends StatefulWidget {
  final RealtorModel realtor;

  const RealtorsProfileView({
    super.key,
    required this.realtor,
  });

  @override
  State<RealtorsProfileView> createState() => _RealtorsProfileViewState();
}

class _RealtorsProfileViewState extends State<RealtorsProfileView> {
  bool _isGridView = true;

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendSms(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _sliverAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildListHeader(context),
                // PropertiesWidgetView(isGridView: _isGridView, removePadding: false),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildListHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "notifications".tr,
            style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                icon: Icon(
                  _isGridView ? IconlyBold.document : IconlyBold.category,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final UserProfilController userProfilController = Get.find<UserProfilController>();
  SliverAppBar _sliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      automaticallyImplyLeading: false,
      leading: IconButton(onPressed: () => Get.back(), icon: Icon(IconlyLight.arrowLeftCircle, color: context.greyColor)),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: kToolbarHeight),
            Container(
              width: 150,
              height: 150,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.transparent, border: Border.all(color: context.greyColor.withOpacity(.4))),
              child: ClipOval(child: CustomWidgets.imageWidget(widget.realtor.img!, false)),
            ),
            Text(widget.realtor.name!, style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 20.sp)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(5, (index) {
                    final ratingValue = double.tryParse(widget.realtor.rating!) ?? 0.0;
                    if (index < ratingValue) {
                      return Icon(IconlyBold.star, color: Colors.amber, size: 16.sp);
                    } else {
                      return Icon(IconlyBold.star, color: Colors.grey.withOpacity(.4), size: 16.sp);
                    }
                  }),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      widget.realtor.rating!,
                      style: context.textTheme.bodyMedium!.copyWith(color: context.greyColor.withOpacity(.7), fontWeight: FontWeight.w500, fontSize: 14.sp),
                    ),
                  )
                ],
              ),
            ),
            Text(
              userProfilController.getTarifText(widget.realtor.typeTitle),
              style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20.h, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(IconlyBold.location, color: context.primaryColor, size: 20),
                  Text(
                    widget.realtor.address.toString(),
                    style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500, fontSize: 13.sp),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () => _sendSms("+993${widget.realtor.username}"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: context.border.lowBorderRadius)),
                        child: Text("sms".tr, style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: context.whiteColor, fontSize: 14.sp))),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () => _makePhoneCall("+993${widget.realtor.username}"),
                        style: ElevatedButton.styleFrom(backgroundColor: context.primaryColor, shape: RoundedRectangleBorder(borderRadius: context.border.lowBorderRadius)),
                        child: Text("call".tr.toUpperCase(), style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: context.whiteColor, fontSize: 14.sp))),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
