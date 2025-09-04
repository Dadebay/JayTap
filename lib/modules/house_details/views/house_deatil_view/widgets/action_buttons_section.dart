import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/chat/views/chat_model.dart';
import 'package:jaytap/modules/chat/views/chat_profil_screen.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/edit_house_view/edit_house_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ActionButtonsSection extends StatelessWidget {
  final int houseID;
  final String? phoneNumber;
  final bool myHouses;
  final PropertyModel house;

  const ActionButtonsSection({
    Key? key,
    required this.houseID,
    this.phoneNumber,
    required this.house,
    required this.myHouses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(12),
      child: myHouses
          ? SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(() => EditHouseView(houseId: houseID)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('edit_button'.tr, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16)),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.to(() => ChatScreen(
                            conversation: Conversation(id: house.owner!.id, createdAt: DateTime.now()),
                            userModel: ChatUser(
                                id: house.owner!.id,
                                username: house.owner!.username!,
                                name: house.owner!.name!,
                                blok: false,
                                rating: house.owner!.rating.toString(),
                                productCount: 0,
                                premiumCount: 0,
                                viewCount: 0),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('sms_button'.tr, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (phoneNumber != null && phoneNumber!.isNotEmpty) {
                        final Uri _url = Uri.parse('tel:+993$phoneNumber');
                        if (!await launchUrl(_url)) {
                          Get.snackbar('error'.tr, 'could_not_launch_dialer'.tr);
                        }
                      } else {
                        Get.snackbar('error'.tr, 'phone_number_not_available'.tr);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('call_button'.tr, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16)),
                  ),
                ),
              ],
            ),
    );
  }
}
