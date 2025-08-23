import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/models/comment_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/action_buttons_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/additional_features_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/description_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/house_header_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/house_image_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/map_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/primary_details_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/realtor_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/review_section.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

import '../../controllers/house_details_controller.dart';

class HouseDetailsView extends StatelessWidget {
  HouseDetailsView({required this.houseID, super.key, required this.myHouses}) {
    controller.fetchHouseDetails(houseID);
  }
  final int houseID;
  final bool myHouses;

  final HouseDetailsController controller = Get.put(HouseDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 255, 255, 255).withOpacity(0.95),
      body: Obx(() {
        if (controller.isLoadingHouse.value) {
          return CustomWidgets.loader();
        }
        if (controller.house.value == null) {
          return CustomWidgets.emptyData();
        }
        final house = controller.house.value!;

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
                    child: const Text('Kartadan görnüşi elýeterli däl.'),
                  ),
                const Divider(thickness: 1, height: 1),
                if (!myHouses)
                  ReviewSection(
                      houseID: house.id,
                      comments: house.comments != null
                          ? (house.comments as List)
                              .map((data) => CommentModel.fromJson(data))
                              .toList()
                          : []),
                ActionButtonsSection(
                  myHouses: myHouses,
                  houseID: house.id,
                  phoneNumber: house.phoneNumber,
                ),
              ],
            ));
      }),
    );
  }
}
