import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/home/components/properties_widget_view.dart';
import 'package:jaytap/modules/home/models/realtor_model.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:kartal/kartal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

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

  Future<void> _rateRealtor(int rating) async {
    final token = await AuthStorage().token;
    if (token == null) {
      return;
    }

    final url = Uri.parse(
        '${ApiConstants.baseUrl}functions/rate/${widget.realtor.id}/');
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['rate'] = rating.toString();
    print('API URL: $url');
    print('Request Body: ${request.fields}');

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('API Response: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        _showSuccessDialog();
      } else {
        Get.back();
        print('Puan gönderilemedi. Hata kodu: ${response}');
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Hata', 'Bir sorun oluştu: $e');
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(IconlyBold.tickSquare, color: Colors.green, size: 50),
              const SizedBox(height: 16),
              Text(
                'Ustunlikli',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bahalandyrma ugradyldy habar bereris',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () => Get.back(),
                child: Text(
                  'Ayyr',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingDialog() {
    var selectedRating = 0.obs;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Ulanyjy bahalandyr',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        selectedRating.value = index + 1;
                      },
                      icon: Icon(
                        index < selectedRating.value
                            ? IconlyBold.star
                            : IconlyLight.star,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Yyldyzy el bilen saylap bolyar",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Ayyr',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: selectedRating.value == 0
                          ? null
                          : () {
                              _rateRealtor(selectedRating.value);
                            },
                      child: Text(
                        'Ugrat',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // <<< YENI FONKSIYONLAR BITIŞ >>>

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
                PropertiesWidgetView(
                  isGridView: _isGridView,
                  removePadding: false,
                  myHouses: false,
                  properties: [],
                  realtorId: widget.realtor.id,
                ),
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
            style: context.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
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

  final UserProfilController userProfilController =
      Get.find<UserProfilController>();
  SliverAppBar _sliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      automaticallyImplyLeading: false,
      leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(IconlyLight.arrowLeftCircle, color: context.greyColor)),
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
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(color: context.greyColor.withOpacity(.4))),
              child: ClipOval(
                  child: CustomWidgets.imageWidget(widget.realtor.img!, false)),
            ),
            Text(widget.realtor.name!,
                style: context.textTheme.bodyMedium!
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 20.sp)),
            //Reitng
            GestureDetector(
              onTap: _showRatingDialog, // <<< DEĞİŞİKLİK BURADA
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(5, (index) {
                      final ratingValue =
                          double.tryParse(widget.realtor.rating.toString()) ??
                              0.0;
                      if (index < ratingValue) {
                        return Icon(IconlyBold.star,
                            color: Colors.amber, size: 16.sp);
                      } else {
                        return Icon(IconlyBold.star,
                            color: Colors.grey.withOpacity(.4), size: 16.sp);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        widget.realtor.rating!.toString(),
                        style: context.textTheme.bodyMedium!.copyWith(
                            color: context.greyColor.withOpacity(.7),
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp),
                      ),
                    )
                  ],
                ),
              ),
            ),
            //
            Text(
              userProfilController.getTarifText(widget.realtor.typeTitle),
              style: context.textTheme.bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 20.h, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(IconlyBold.location,
                      color: context.primaryColor, size: 20),
                  Text(
                    widget.realtor.address.toString(),
                    style: context.textTheme.bodyMedium!
                        .copyWith(fontWeight: FontWeight.w500, fontSize: 13.sp),
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
                        onPressed: () =>
                            _sendSms("+993${widget.realtor.username}"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: context.border.lowBorderRadius)),
                        child: Text("sms".tr,
                            style: context.textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.whiteColor,
                                fontSize: 14.sp))),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () =>
                            _makePhoneCall("+993${widget.realtor.username}"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: context.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: context.border.lowBorderRadius)),
                        child: Text("call".tr.toUpperCase(),
                            style: context.textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.whiteColor,
                                fontSize: 14.sp))),
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
