// lib/modules/realtors/views/show_all_realtors.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/components/realtor_grid_card.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/shared/widgets/custom_app_bar.dart';
import 'package:jaytap/shared/widgets/widgets.dart'; // CustomWidgets.loader() için

class ShowAllRealtors extends GetView<HomeController> {
  ShowAllRealtors({super.key});
  final HomeController _homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'realtor', showBackButton: true), // 'realtor' -> 'realtors'.tr daha doğru olabilir
      body: Obx(() {
        if (controller.isLoadingRealtors.value) {
          return CustomWidgets.loader();
        }
        if (controller.realtorList.isEmpty) {
          return Center(
            child: Text('no_realtors_found'.tr), // Çeviri anahtarı ekleyin
          );
        }

        // Veriler geldiyse GridView'i oluştur
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.realtorList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 sütun
            crossAxisSpacing: 16, // Yatay boşluk
            mainAxisSpacing: 16, // Dikey boşluk
            childAspectRatio: 0.70, // Kartların en-boy oranı (tasarıma göre ayarlayabilirsiniz)
          ),
          itemBuilder: (context, index) {
            final realtor = controller.realtorList[index];
            return RealtorGridCard(realtor: realtor);
          },
        );
      }),
    );
  }
}
