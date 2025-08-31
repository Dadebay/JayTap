import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:jaytap/modules/house_details/models/comment_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/action_buttons_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/additional_features_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/description_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/house_header_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/house_image_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/map_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/nearby_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/primary_details_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/realtor_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/review_section.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/spesifivation.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:jaytap/shared/dialogs/dialogs_utils.dart';
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
      backgroundColor: Theme.of(context).colorScheme.background,
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
                HouseHeaderSection(house: house, myHouses: myHouses),
                if (house.owner != null) RealtorSection(owner: house.owner!),
                PrimaryDetailsSection(house: house),
                SpecificationsSection(
                    specifications: house.specifications ?? []),
                NearbyPlacesSection(nearbyPlaces: house.sphere ?? []),
                AdditionalFeaturesSection(house: house),
                DescriptionSection(house: house),
                if (house.lat != null && house.long != null)
                  MapSection(house: house)
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Text('section_12'.tr),
                  ),
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.4)
                            : Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 2,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'zalobTitle'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            HugeIcons.strokeRoundedFlag03,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () {
                            DialogUtils().showZalobaDialog(
                                context, controller, house.id);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (!myHouses)
                  ReviewSection(
                      houseID: house.id,
                      comments: house.comments != null
                          ? (house.comments as List)
                              .map((data) => CommentModel.fromJson(data))
                              .toList()
                          : []),
                const SizedBox(height: 5),
              ],
            ));
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoadingHouse.value || controller.house.value == null) {
          return const SizedBox.shrink();
        }
        return ActionButtonsSection(
          myHouses: myHouses,
          houseID: controller.house.value!.id,
          phoneNumber: controller.house.value!.phoneNumber,
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
