import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/views/edit_house_view/edit_house_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ActionButtonsSection extends StatelessWidget {
  final int houseID;
  final String? phoneNumber;
  final bool myHouses;

  const ActionButtonsSection({
    Key? key,
    required this.houseID,
    this.phoneNumber,
    required this.myHouses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        10.0,
        12.0,
        10.0,
        12.0,
      ),
      child: myHouses
          ? SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(() => EditHouseView(houseId: houseID)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Edit',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (phoneNumber != null && phoneNumber!.isNotEmpty) {
                        final Uri _url = Uri.parse('sms:+993$phoneNumber');
                        if (!await launchUrl(_url)) {
                          Get.snackbar('Error', 'Could not launch SMS app.');
                        }
                      } else {
                        Get.snackbar('Error', 'Phone number not available.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('SMS',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (phoneNumber != null && phoneNumber!.isNotEmpty) {
                        final Uri _url = Uri.parse('tel:+993$phoneNumber');
                        if (!await launchUrl(_url)) {
                          Get.snackbar('Error', 'Could not launch dialer.');
                        }
                      } else {
                        Get.snackbar('Error', 'Phone number not available.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Jaň etmek',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
    );
  }
}
