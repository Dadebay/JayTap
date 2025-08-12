// lib/modules/house_details/views/house_details_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import '../controllers/house_details_controller.dart';

class HouseDetailsView extends StatelessWidget {
  HouseDetailsView({required this.houseID, super.key});
  final int houseID;
  final HouseDetailsController controller = Get.put(HouseDetailsController());

  @override
  Widget build(BuildContext context) {
    // Controller'ı `houseID` ile birlikte oluştur.

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan Detayı'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showZalobaDialog(context, controller),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'İlan ID: $houseID',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  void _showZalobaDialog(BuildContext context, HouseDetailsController controller) {
    controller.fetchZalobaReasons();

    Get.defaultDialog(
      title: "Şikayet Et",
      titlePadding: EdgeInsets.all(20),
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      content: Obx(() {
        if (controller.isLoadingZaloba.value) {
          return SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        }

        return SizedBox(
          width: Get.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hazır nedenler için kaydırılabilir liste
              SizedBox(
                height: Get.height * 0.3, // Yüksekliği ayarla
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.zalobaReasons.length + 1, // +1 "Diğer" için
                  itemBuilder: (context, index) {
                    if (index < controller.zalobaReasons.length) {
                      final reason = controller.zalobaReasons[index];
                      return RadioListTile<int>(
                        title: Text(reason.titleTm), // Veya dil seçimine göre
                        value: reason.id,
                        groupValue: controller.selectedZalobaId.value,
                        onChanged: controller.selectZaloba,
                      );
                    } else {
                      // "Diğer" seçeneği
                      return RadioListTile<int>(
                        title: Text("Başga bir zalob"),
                        value: controller.otherOptionId,
                        groupValue: controller.selectedZalobaId.value,
                        onChanged: controller.selectZaloba,
                      );
                    }
                  },
                ),
              ),

              // "Diğer" seçilince görünecek metin alanı
              if (controller.selectedZalobaId.value == controller.otherOptionId)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: TextField(
                    controller: controller.customZalobaController,
                    decoration: InputDecoration(
                      labelText: "Şikayetinizi yazın",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
            ],
          ),
        );
      }),
      // Onay ve İptal Butonları
      confirm: Obx(() => ElevatedButton(
            onPressed: () {
              if (controller.selectedZalobaId.value == null) {
                CustomWidgets.showSnackBar("Error", "Select Zalob", Colors.red);
              } else {
                controller.submitZaloba(houseId: houseID);
                // int.parse(controller.selectedZalobaId.value.toString())
              }
            },
            child: controller.isSubmittingZaloba.value ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text("Gönder"),
          )),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text("İptal"),
      ),
    );
  }
}
