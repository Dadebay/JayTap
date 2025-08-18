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

import '../../controllers/house_details_controller.dart';

class HouseDetailsView extends StatelessWidget {
  HouseDetailsView({required this.houseID, super.key});
  final int houseID;
  final HouseDetailsController controller = Get.put(HouseDetailsController());
  final PropertyService _houseDetailService = PropertyService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: FutureBuilder<PropertyModel?>(
        future: _houseDetailService.getHouseDetail(houseID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Bildiriş tapylmady.'));
          }

          final house = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HouseImageSection(house: house),
                HouseHeaderSection(house: house),
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
                ActionButtonsSection(),
              ],
            ),
          );
        },
      ),
    );
  }
}
