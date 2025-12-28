import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/modules/chat/views/chat_model.dart';
import 'package:jaytap/modules/chat/views/chat_profil_screen.dart';
import 'package:jaytap/modules/chat/controllers/chat_controller.dart';
import 'package:jaytap/modules/house_details/controllers/edit_house_controller.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/edit_house_view/edit_house_view.dart';
import 'package:jaytap/shared/dialogs/dialogs_utils.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../user_profile/controllers/user_profile_controller.dart';
import '../../../../../core/services/auth_storage.dart';

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

  Future<void> deleteHouse(int houseId) async {
    print('Deleting house with ID: $houseId');
    final apiService = ApiService();
    final result = await apiService.handleApiRequest(
      'api/product/$houseId/',
      body: {},
      method: 'DELETE',
      requiresToken: true,
    );
    print('API Response: $result');
    if (result != null && result >= 200 && result < 300) {
      if (Get.isRegistered<UserProfilController>()) {
        Get.find<UserProfilController>().removeProductById(houseId);
      }
      Get.back(); // Close the details page
      CustomWidgets.showSnackBar(
        'success'.tr,
        'house_deleted_successfully'.tr,
        Colors.green,
      );
    } else {
      CustomWidgets.showSnackBar(
        'error'.tr,
        'failed_to_delete_house'.tr,
        Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(12),
      child: myHouses
          ? Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      DialogUtils.showDeleteConfirmationDialog(
                        context,
                        'delete_house_title'.tr,
                        'are_you_sure_delete_house'.tr,
                        () {
                          deleteHouse(houseID);
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('delete'.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.find<EditHouseController>()
                          .loadHouseForEditing(houseID);
                      Get.to(() => EditHouseView());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('edit_button'.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 16)),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final authStorage = AuthStorage();
                      final token = await authStorage.token;
                      if (token == null) {
                        CustomWidgets.showSnackBar(
                          "notification".tr,
                          "please_login".tr,
                          Colors.red,
                        );
                        return;
                      }

                      final chatUser = ChatUser(
                          id: house.owner!.id,
                          username: house.owner!.username!,
                          name: house.owner!.name!,
                          blok: false,
                          rating: house.owner!.rating.toString(),
                          productCount: 0,
                          premiumCount: 0,
                          viewCount: 0);

                      ChatController controller;
                      if (Get.isRegistered<ChatController>()) {
                        controller = Get.find<ChatController>();
                      } else {
                        controller = Get.put(ChatController());
                      }

                      final conversation =
                          await controller.startConversation(chatUser);

                      if (conversation != null) {
                        Get.to(() => ChatScreen(
                              conversation: conversation,
                              userModel: chatUser,
                            ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('sms_button'.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (phoneNumber != null && phoneNumber!.isNotEmpty) {
                        final Uri _url = Uri.parse('tel:+993$phoneNumber');
                        if (!await launchUrl(_url)) {
                          Get.snackbar(
                              'error'.tr, 'could_not_launch_dialer'.tr);
                        }
                      } else {
                        Get.snackbar(
                            'error'.tr, 'phone_number_not_available'.tr);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('call_button'.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 16)),
                  ),
                ),
              ],
            ),
    );
  }
}
