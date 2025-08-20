import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/related_houses/controllers/related_houses_controller.dart';

class RelatedHousesView extends GetView<RelatedHousesController> {
  final List<int>? propertyIds;
  final Map<String, dynamic>? arguments;

  const RelatedHousesView({super.key, this.propertyIds, this.arguments});

  @override
  Widget build(BuildContext context) {
    // Access the controller
    final RelatedHousesController controller = Get.find<RelatedHousesController>();

    // The filter data is now passed via the constructor, so we pass it to the controller
    // This assumes the controller is initialized with the arguments.
    // We will adjust the controller's binding to pass these arguments.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Related Houses'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.houses.isEmpty) {
          return const Center(child: Text('Boş')); // "Boş" means empty
        } else {
          return ListView.builder(
            itemCount: controller.houses.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('House ID: \${house.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Floor Count: \${house.floorcount}'),
                      Text('Room Count: \${house.roomcount}'),
                      // Add more house details as needed
                    ],
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}
