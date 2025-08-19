import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/models/comment_model.dart';
// Doğru modeli import ettiğinizden emin olun
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/service/property_service.dart';
import 'package:jaytap/modules/house_details/views/edit_house_view/edit_house_view.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/action_buttons_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/additional_features_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/description_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/house_header_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/house_image_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/map_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/primary_details_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/realtor_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/review_section.dart';
// import 'package:jaytap/modules/panorama/panorama_page.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

import '../../controllers/house_details_controller.dart';

class HouseDetailsView extends StatelessWidget {
  HouseDetailsView({required this.houseID, super.key, required this.myHouses});
  final int houseID;
  final bool myHouses;

  final HouseDetailsController controller = Get.put(HouseDetailsController());
  final PropertyService _houseDetailService = PropertyService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<PropertyModel?>(
        future: _houseDetailService.getHouseDetail(houseID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomWidgets.loader();
          }
          if (snapshot.hasError) {
            return CustomWidgets.errorFetchData();
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return CustomWidgets.emptyData();
          }
          final house = snapshot.data!;

          return SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (myHouses)
                    AppBar(
                      title: const Text("Bildiriş Detallary"),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Get.to(() => EditHouseView(houseId: houseID));
                          },
                        ),
                      ],
                    ),
                  HouseImageSection(house: house),
                  HouseHeaderSection(house: house),
                  if (house.vr != null && house.vr!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.threesixty),
                          label: const Text("360° Görüntüle"),
                          onPressed: () {
                            // Yeni PanoramaViewPage'i doğru veri ile aç
                            // Get.to(() => PanoramaViewPage(vrData: house.vr!));
                          },
                        ),
                      ),
                    ),
                  if (house.owner != null) RealtorSection(owner: house.owner!),
                  PrimaryDetailsSection(house: house),
                  const Divider(thickness: 1, height: 1),
                  AdditionalFeaturesSection(house: house),
                  const Divider(thickness: 1, height: 1),
                  DescriptionSection(house: house),
                  const Divider(thickness: 1, height: 1),
                  if (house.lat != null && house.long != null)
                    MapSection(house: house)
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.center,
                      child: const Text('Kartdan görnüşi elýeterli däl.'),
                    ),
                  const Divider(thickness: 1, height: 1),
                  ReviewSection(
                      houseID: house.id,
                      comments: house.comments != null
                          ? (house.comments as List)
                              .map((data) => CommentModel.fromJson(data))
                              .toList()
                          : []),
                  ActionButtonsSection(
                    houseID: house.id,
                    phoneNumber: house.phoneNumber,
                    isOwner: false,
                  ),
                ],
              ));
        },
      ),
    );
  }
}
