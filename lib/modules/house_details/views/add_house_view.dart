import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/controllers/add_house_controller.dart';
import 'dart:io';

import 'package:jaytap/shared/widgets/agree_button.dart'; // XFile'ı File'a çevirmek için

class AddHouseView extends StatefulWidget {
  const AddHouseView({super.key});

  @override
  State<AddHouseView> createState() => _AddHouseViewState();
}

class _AddHouseViewState extends State<AddHouseView> {
  final AddHouseController controller = Get.put(AddHouseController());

  @override
  void initState() {
    super.initState();
    controller.fetchInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditMode.value ? 'Bildirişi üýtgetmek' : 'add_property')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection('select_city', _buildCitySelector()),
          _buildSection('select_city_title', ElevatedButton(onPressed: () {}, child: Text('select_city_subtitle'.tr))),
          _buildSection('show_in_map', _buildMapPlaceholder()),
          _buildSection('image_add', _buildImagePicker(controller)),
          _buildSection('meydany', _buildTextField(controller.areaController, '200', 'm²')),
          _buildSection('property_gat_sany', _buildFloorSelector(controller)),
          _buildSection('spesification', _buildRoomDetails(controller)),
          _buildSection('price', _buildTextField(controller.priceController, '200.000', 'TMT')),
          _buildSection('Gürsaw', _buildAmenitiesButton(controller)),
          _buildSection('Telefon belgiňiz', _buildTextField(controller.phoneController, '6X XXXXXX', null, prefix: '+993 ')),
          const SizedBox(height: 20),
          _buildBottomButtons(controller),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        child,
        const SizedBox(height: 24),
      ],
    );
  }

  // DEĞİŞİKLİK: Bu fonksiyon artık controller'ı parametre olarak alıyor
  Widget _buildCitySelector() {
    return Obx(() {
      if (controller.isLoadingVillages.value) {
        return const SizedBox(height: 45, child: Center(child: CircularProgressIndicator()));
      }
      if (controller.villages.isEmpty) {
        return const SizedBox(height: 45, child: Center(child: Text('Şäher tapylmady')));
      }

      return SizedBox(
        height: 45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.villages.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => controller.selectVillage(controller.villages[index].id),
              child: Container(
                margin: const EdgeInsets.only(right: 10.0),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: controller.selectedVillageId.value == controller.villages[index].id ? Get.theme.primaryColor.withOpacity(0.2) : Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: controller.selectedVillageId.value == controller.villages[index].id ? Get.theme.primaryColor : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    controller.villages[index].name ?? '',
                    style: TextStyle(
                      color: controller.selectedVillageId.value == controller.villages[index].id ? Get.theme.primaryColor : Colors.black87,
                      fontWeight: controller.selectedVillageId.value == controller.villages[index].id ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildToggleButtons(List<String> options, RxInt selectedIndex, Function(int) onSelected, {bool isFixed = false}) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ToggleButtons(
            isSelected: List.generate(options.length, (i) => i == selectedIndex.value),
            onPressed: onSelected,
            borderRadius: BorderRadius.circular(8.0),
            constraints: BoxConstraints(minHeight: 40, minWidth: isFixed ? (Get.width - 36) / options.length : 0 // Fixed width for sale type
                ),
            children: options.map((item) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Text(item))).toList(),
          )),
    );
  }

  Widget _buildMapPlaceholder() => Container(
        height: 150,
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Text('Map Placeholder')),
      );

  Widget _buildImagePicker(AddHouseController c) {
    return Column(
      children: [
        GestureDetector(
          onTap: c.pickImages,
          child: Container(
            height: 80,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                const SizedBox(width: 8),
                Obx(() => Text('Surat saýla (${c.images.length}/10)')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (c.images.isEmpty) return const SizedBox.shrink();
          return SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: c.images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(File(c.images[index].path), width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => c.removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTextField(TextEditingController c, String hint, String? suffix, {String? prefix}) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixText: suffix,
        prefixText: prefix,
      ),
    );
  }

  Widget _buildFloorSelector(AddHouseController c) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 15, // 15 kat gösterelim
        itemBuilder: (context, index) {
          final floor = index + 1;
          return Obx(() => GestureDetector(
                onTap: () => c.selectBuildingFloor(floor),
                child: Container(
                  width: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: c.selectedBuildingFloor.value == floor ? Get.theme.primaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      floor.toString(),
                      style: TextStyle(
                        color: c.selectedBuildingFloor.value == floor ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ));
        },
      ),
    );
  }

  Widget _buildRoomDetails(AddHouseController c) {
    return Column(
      children: [
        _buildStepperRow('Ýatylýan otag', c.livingRoomCount, (change) => c.changeRoomCount(c.livingRoomCount, change)),
        _buildStepperRow('Myhman otag', c.guestRoomCount, (change) => c.changeRoomCount(c.guestRoomCount, change)),
        _buildStepperRow('Kuhnya', c.kitchenCount, (change) => c.changeRoomCount(c.kitchenCount, change)),
        _buildStepperRow('Salon', c.salonCount, (change) => c.changeRoomCount(c.salonCount, change)),
        _buildStepperRow('Hammam', c.bathroomCount, (change) => c.changeRoomCount(c.bathroomCount, change)),
        _buildStepperRow('Jemi otag sany', c.totalRoomCount, (change) => c.changeRoomCount(c.totalRoomCount, change)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: c.showRenovationPicker,
          child: AbsorbPointer(
            child: Obx(() => TextFormField(
                  key: Key(c.selectedRenovation.value ?? ''), // Dropdown gibi davranması için
                  initialValue: c.selectedRenovation.value,
                  decoration: const InputDecoration(labelText: 'Remont', hintText: 'Remondyň görnüşini saýlaň', border: OutlineInputBorder(), suffixIcon: Icon(Icons.arrow_drop_down)),
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildStepperRow(String label, RxInt value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => onChanged(-1)),
              Obx(() => Text(value.value.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => onChanged(1)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAmenitiesButton(AddHouseController c) {
    return OutlinedButton.icon(
      onPressed: c.showAmenitiesPicker,
      icon: const Icon(Icons.add),
      label: const Text('Goşmaça maglumatlar'),
      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
    );
  }

  Widget _buildBottomButtons(AddHouseController c) {
    return Obx(() {
      if (c.isEditMode.value) {
        return Row(
          children: [
            Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Aýyrmak'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red))),
            const SizedBox(width: 16),
            Expanded(child: ElevatedButton(onPressed: c.submitListing, child: const Text('Sazlamalar'))),
          ],
        );
      } else {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: c.submitListing,
            child: const Text('Bildiriş goş'),
          ),
        );
      }
    });
  }
}
