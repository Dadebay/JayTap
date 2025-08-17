import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:jaytap/modules/house_details/controllers/add_house_controller.dart';
import 'package:latlong2/latlong.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isEditMode.value
            ? 'Bildirişi üýtgetmek'
            : 'add_property')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection('select_category', _buildCategorySelector()),
          _buildSection('select_subcategory', _buildSubCategorySelector()),
          _buildSection('select_subIncategory', _buildSubInCategorySelector()),
          _buildSection('select_city', _buildCitySelector()),
          _buildSection('select_region', _buildRegionSelector()),

          _buildSection('show_in_map', _buildMap()),

          _buildSection(
              'Goşmaça maglumat',
              _buildTextField(controller.descriptionController,
                  'Jaý hakda giňişleýin maglumat...', null,
                  maxLines: 5)),
          _buildSection('image_add', _buildImagePicker(controller)),
          _buildSection('meydany',
              _buildTextField(controller.areaController, '200', 'm²')),
          _buildSection(
              'Otag sany',
              _buildRoomSelector(
                controller: controller,
                selectedValue: controller.totalRoomCount,
                onSelected: (value) => controller.totalRoomCount.value = value,
                min: controller.minRoom,
                max: controller.maxRoom,
              )),
          _buildSection(
              'Binanyn gat sany',
              _buildNumberSelector(
                controller: controller,
                selectedValue: controller.totalFloorCount,
                onSelected: (value) => controller.totalFloorCount.value = value,
                min: controller.minFloor,
                max: controller.maxFloor,
              )),
          _buildSection('Yerleşen Gat', _buildFloorSelector(controller)),

          //
          _buildSection('spesification', _buildRoomDetails(controller)),

          //
          _buildSection('price',
              _buildTextField(controller.priceController, '200.000', 'TMT')),
          //
          _buildSection(
              'Gosmaca maglumatlar', _buildAmenitiesButton(controller)),
          _buildSection(
              'Telefon belgiňiz',
              _buildTextField(controller.phoneController, '6X XXXXXX', null,
                  prefix: '+993 ')),

          _buildSection('Gurşow', _buildSpheresButton(controller)),
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
        Text(title.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        child,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCitySelector() {
    return SizedBox(
      height: 45,
      child: Obx(() {
        if (controller.isLoadingVillages.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.villages.isEmpty) {
          return const Center(child: Text('Şäher tapylmady'));
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.villages.length,
          itemBuilder: (context, index) {
            final village = controller.villages[index];
            return Obx(() {
              final isSelected =
                  controller.selectedVillageId.value == village.id;
              return GestureDetector(
                onTap: () => controller.selectVillage(village.id),
                child: Container(
                  margin: const EdgeInsets.only(right: 10.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Get.theme.primaryColor.withOpacity(0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isSelected
                          ? Get.theme.primaryColor
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      village.name ?? '',
                      style: TextStyle(
                        color: isSelected
                            ? Get.theme.primaryColor
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  Widget _buildRegionSelector() {
    return SizedBox(
      height: 45,
      child: Obx(() {
        if (controller.isLoadingRegions.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.regions.isEmpty) {
          return const Center(child: Text('Etrap tapylmady'));
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.regions.length,
          itemBuilder: (context, index) {
            final region = controller.regions[index];
            return Obx(() {
              final isSelected = controller.selectedRegionId.value == region.id;
              return GestureDetector(
                onTap: () => controller.selectRegion(region.id),
                child: Container(
                  margin: const EdgeInsets.only(right: 10.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Get.theme.primaryColor.withOpacity(0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isSelected
                          ? Get.theme.primaryColor
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      region.name ?? '',
                      style: TextStyle(
                        color: isSelected
                            ? Get.theme.primaryColor
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 45,
      child: Obx(() {
        if (controller.isLoadingCategories.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.categories.isEmpty) {
          return const Center(child: Text('Kategoriýa tapylmady'));
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return Obx(() {
              final isSelected =
                  controller.selectedCategoryId.value == category.id;
              return GestureDetector(
                onTap: () => controller.selectCategory(category.id),
                child: Container(
                  margin: const EdgeInsets.only(right: 10.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Get.theme.primaryColor.withOpacity(0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isSelected
                          ? Get.theme.primaryColor
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category.name ?? '',
                      style: TextStyle(
                        color: isSelected
                            ? Get.theme.primaryColor
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  Widget _buildSubCategorySelector() {
    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return const SizedBox.shrink();
      }
      if (controller.subCategories.isEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.subCategories.length,
          itemBuilder: (context, index) {
            final subCategory = controller.subCategories[index];
            return Obx(() {
              final isSelected =
                  controller.selectedSubCategoryId.value == subCategory.id;
              return GestureDetector(
                onTap: () => controller.selectSubCategory(subCategory.id!),
                child: Container(
                  margin: const EdgeInsets.only(right: 10.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Get.theme.primaryColor.withOpacity(0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isSelected
                          ? Get.theme.primaryColor
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      subCategory.name ?? '',
                      style: TextStyle(
                        color: isSelected
                            ? Get.theme.primaryColor
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      );
    });
  }

  Widget _buildSubInCategorySelector() {
    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return const SizedBox.shrink();
      }
      if (controller.subinCategories.isEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.subinCategories.length,
          itemBuilder: (context, index) {
            final subCategory = controller.subinCategories[index];
            return Obx(() {
              final isSelected =
                  controller.selectedInSubCategoryId.value == subCategory.id;
              return GestureDetector(
                onTap: () => controller.selectSubIncategory(subCategory.id!),
                child: Container(
                  margin: const EdgeInsets.only(right: 10.0),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Get.theme.primaryColor.withOpacity(0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isSelected
                          ? Get.theme.primaryColor
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      subCategory.name ?? '',
                      style: TextStyle(
                        color: isSelected
                            ? Get.theme.primaryColor
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      );
    });
  }

  Widget _buildMap() {
    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Obx(
              () => FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: controller.selectedLocation.value ??
                      const LatLng(37.95, 58.38),
                  initialZoom: 13.0,
                  onMapReady: () {
                    controller.onMapReadyCallback();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'http://216.250.10.237:8080/styles/test-style/{z}/{x}/{y}.png',
                    maxZoom: 18,
                    minZoom: 5,
                    userAgentPackageName: 'com.gurbanov.jaytap',
                    errorTileCallback: (tile, error, stackTrace) {
                      print(
                          "HARİTA TILE HATASI: Tile: ${tile.coordinates}, Hata: $error");
                    },
                  ),
                  Obx(() => MarkerLayer(markers: controller.markers.toList())),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.fullscreen),
                onPressed: controller.openFullScreenMap,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(AddHouseController c) {
    return Column(
      children: [
        GestureDetector(
          onTap: c.pickImages,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!)),
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
                        child: Image.file(File(c.images[index].path),
                            width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => c.removeImage(index),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 18),
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

  Widget _buildTextField(TextEditingController c, String hint, String? suffix,
      {String? prefix, int? maxLines = 1}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixText: suffix,
        prefixText: prefix,
      ),
    );
  }

  Widget _buildFloorSelector(AddHouseController c) {
    return Obx(() {
      if (c.minFloor.value == 0 && c.maxFloor.value == 0) {
        return const Center(child: CircularProgressIndicator());
      }
      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: c.maxFloor.value - c.minFloor.value + 1,
          itemBuilder: (context, index) {
            final floor = c.minFloor.value + index;
            return Obx(() => GestureDetector(
                  onTap: () => c.selectBuildingFloor(floor),
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: c.selectedBuildingFloor.value == floor
                          ? Get.theme.primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        floor.toString(),
                        style: TextStyle(
                          color: c.selectedBuildingFloor.value == floor
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ));
          },
        ),
      );
    });
  }

  Widget _buildRoomSelector({
    required AddHouseController controller,
    required RxInt selectedValue,
    required ValueChanged<int> onSelected,
    required RxInt min,
    required RxInt max,
  }) {
    return Obx(() {
      if (min.value == 0 && max.value == 0) {
        return const Center(child: CircularProgressIndicator());
      }
      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: max.value - min.value + 1,
          itemBuilder: (context, index) {
            final number = min.value + index;
            return Obx(() => GestureDetector(
                  onTap: () => onSelected(number),
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: selectedValue.value == number
                          ? Get.theme.primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        number.toString(),
                        style: TextStyle(
                          color: selectedValue.value == number
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ));
          },
        ),
      );
    });
  }

  Widget _buildNumberSelector({
    required AddHouseController controller,
    required RxInt selectedValue,
    required ValueChanged<int> onSelected,
    required RxInt min,
    required RxInt max,
  }) {
    return Obx(() {
      if (min.value == 0 && max.value == 0) {
        return const Center(child: CircularProgressIndicator());
      }
      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: max.value - min.value + 1,
          itemBuilder: (context, index) {
            final number = min.value + index;
            return Obx(() => GestureDetector(
                  onTap: () => onSelected(number),
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: selectedValue.value == number
                          ? Get.theme.primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        number.toString(),
                        style: TextStyle(
                          color: selectedValue.value == number
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ));
          },
        ),
      );
    });
  }

  Widget _buildRoomDetails(AddHouseController c) {
    return Obx(() {
      if (c.isLoadingSpecifications.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (c.specifications.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: c.specifications.length,
            itemBuilder: (context, index) {
              final specification = c.specifications[index];
              return _buildIndividualRoomStepper(
                specification.name ?? '',
                c.specificationCounts[specification.id]!,
                (change) =>
                    c.changeSpecificationCount(specification.id, change),
              );
            },
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: c.showRenovationPicker,
            child: AbsorbPointer(
              child: Obx(() => TextFormField(
                    key: Key(c.selectedRenovation.value ?? ''),
                    initialValue: c.selectedRenovation.value,
                    decoration: const InputDecoration(
                        labelText: 'Remont',
                        hintText: 'Remondyň görnüşini saýlaň',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down)),
                  )),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildIndividualRoomStepper(
      String label, RxInt value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Row(
            children: [
              IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => onChanged(-1)),
              Obx(() => Text(value.value.toString(),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold))),
              IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => onChanged(1)),
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
      style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50)),
    );
  }

  Widget _buildBottomButtons(AddHouseController c) {
    return Obx(() {
      if (c.isEditMode.value) {
        return Row(
          children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Aýyrmak'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red))),
            const SizedBox(width: 16),
            Expanded(
                child: ElevatedButton(
                    onPressed: c.submitListing,
                    child: const Text('Sazlamalar'))),
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

  Widget _buildSpheresButton(AddHouseController c) {
    return Obx(() {
      if (c.isLoadingSpheres.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (c.spheres.isEmpty) {
        return const Center(child: Text('No spheres found'));
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: c.spheres.map((sphere) {
          final isSelected = c.selectedSpheres.contains(sphere);

          return ChoiceChip(
            label: Text(
              sphere.name ?? '',
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            selectedColor: Colors.blue.withOpacity(0.1),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.grey.shade400,
                width: 1,
              ),
            ),
            onSelected: (val) {
              if (val) {
                c.selectedSpheres.add(sphere);
              } else {
                c.selectedSpheres.remove(sphere);
              }
            },
          );
        }).toList(),
      );
    });
  }
}
