
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/house_details/controllers/edit_house_controller.dart';
import 'package:latlong2/latlong.dart';

class EditHouseView extends StatelessWidget {
  final int houseId;
  const EditHouseView({super.key, required this.houseId});

  @override
  Widget build(BuildContext context) {
    final EditHouseController controller = Get.put(EditHouseController(houseId: houseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit House'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildBody(controller);
      }),
    );
  }

  Widget _buildBody(EditHouseController controller) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _Section(
          title: 'Category',
          child: _CategorySelector(controller: controller),
        ),
        _Section(
          title: 'Subcategory',
          child: _SubCategorySelector(controller: controller),
        ),
        _Section(
          title: 'Sub-in-category',
          child: _SubInCategorySelector(controller: controller),
        ),
        _Section(
          title: 'City',
          child: _CitySelector(controller: controller),
        ),
        _Section(
          title: 'Region',
          child: _RegionSelector(controller: controller),
        ),
        _Section(title: 'Map', child: _Map(controller: controller)),
        _Section(
          title: 'Description',
          child: _TextField(
            controller: controller.descriptionController,
            hint: 'Detailed information about the house...',
            maxLines: 5,
          ),
        ),
        _Section(title: 'Images', child: _ImagePicker(controller: controller)),
        _Section(
          title: 'Area',
          child: _TextField(
            controller: controller.areaController,
            hint: '200',
            suffix: 'm²',
          ),
        ),
        _Section(
          title: 'Number of Rooms',
          child: _NumberSelector(
            selectedValue: controller.totalRoomCount,
            onSelected: (value) => controller.totalRoomCount.value = value,
            min: controller.minRoom,
            max: controller.maxRoom,
          ),
        ),
        _Section(
          title: 'Total Floors',
          child: _NumberSelector(
            selectedValue: controller.totalFloorCount,
            onSelected: (value) => controller.totalFloorCount.value = value,
            min: controller.minFloor,
            max: controller.maxFloor,
          ),
        ),
        _Section(
          title: 'Floor',
          child: _FloorSelector(controller: controller),
        ),
        _Section(
          title: 'Specifications',
          child: _RoomDetails(controller: controller),
        ),
        _Section(
          title: 'Price',
          child: _TextField(
            controller: controller.priceController,
            hint: '200.000',
            suffix: 'TMT',
          ),
        ),
        _Section(
          title: 'Additional Information',
          child: _AmenitiesButton(controller: controller),
        ),
        _Section(
          title: 'Phone Number',
          child: _TextField(
            controller: controller.phoneController,
            hint: '6X XXXXXX',
            prefix: '+993 ',
          ),
        ),
        _Section(
            title: 'Environment',
            child: _SpheresButton(controller: controller)),
        const SizedBox(height: 20),
        _BottomButtons(controller: controller),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.tr, style: Get.textTheme.titleLarge),
        const SizedBox(height: 12),
        child,
        const SizedBox(height: 24),
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? suffix;
  final String? prefix;
  final int? maxLines;

  const _TextField({
    required this.controller,
    required this.hint,
    this.suffix,
    this.prefix,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixText: suffix,
        prefixText: prefix,
      ),
    );
  }
}

class _SelectorItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectorItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Get.theme.primaryColor.withOpacity(0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? Get.theme.primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Get.theme.primaryColor : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _CitySelector extends StatelessWidget {
  final EditHouseController controller;

  const _CitySelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Obx(() {
        if (controller.villages.isEmpty) {
          return const Center(child: Text('No cities found'));
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.villages.length,
          itemBuilder: (context, index) {
            final village = controller.villages[index];
            return Obx(() => _SelectorItem(
                  label: village.name ?? '',
                  isSelected: controller.selectedVillageId.value == village.id,
                  onTap: () => controller.selectVillage(village.id),
                ));
          },
        );
      }),
    );
  }
}

class _RegionSelector extends StatelessWidget {
  final EditHouseController controller;

  const _RegionSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Obx(() {
        if (controller.regions.isEmpty) {
          return const Center(child: Text('No regions found'));
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.regions.length,
          itemBuilder: (context, index) {
            final region = controller.regions[index];
            return Obx(() => _SelectorItem(
                  label: region.name ?? '',
                  isSelected: controller.selectedRegionId.value == region.id,
                  onTap: () => controller.selectRegion(region.id),
                ));
          },
        );
      }),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final EditHouseController controller;

  const _CategorySelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Obx(() {
        if (controller.categories.isEmpty) {
          return const Center(child: Text('No categories found'));
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return Obx(() => _SelectorItem(
                  label: category.name ?? '',
                  isSelected:
                      controller.selectedCategoryId.value == category.id,
                  onTap: () => controller.selectCategory(category.id),
                ));
          },
        );
      }),
    );
  }
}

class _SubCategorySelector extends StatelessWidget {
  final EditHouseController controller;

  const _SubCategorySelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
            return Obx(() => _SelectorItem(
                  label: subCategory.name ?? '',
                  isSelected:
                      controller.selectedSubCategoryId.value == subCategory.id,
                  onTap: () => controller.selectSubCategory(subCategory.id!),
                ));
          },
        ),
      );
    });
  }
}

class _SubInCategorySelector extends StatelessWidget {
  final EditHouseController controller;

  const _SubInCategorySelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
            return Obx(() => _SelectorItem(
                  label: subCategory.name ?? '',
                  isSelected: controller.selectedInSubCategoryId.value ==
                      subCategory.id,
                  onTap: () => controller.selectSubIncategory(subCategory.id!),
                ));
          },
        ),
      );
    });
  }
}

class _Map extends StatelessWidget {
  final EditHouseController controller;

  const _Map({required this.controller});

  @override
  Widget build(BuildContext context) {
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
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'http://216.250.10.237:8080/styles/test-style/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.gurbanov.jaytap',
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
}

class _ImagePicker extends StatelessWidget {
  final EditHouseController controller;

  const _ImagePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: controller.pickImages,
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
                Obx(() =>
                    Text('Select Images (${controller.images.length}/10)')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.images.isEmpty) return const SizedBox.shrink();
          return SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.images.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(File(controller.images[index].path),
                            width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => controller.removeImage(index),
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
}

class _FloorSelector extends StatelessWidget {
  final EditHouseController controller;

  const _FloorSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.minFloor.value == 0 && controller.maxFloor.value == 0) {
        return const Center(child: CircularProgressIndicator());
      }
      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.maxFloor.value - controller.minFloor.value + 1,
          itemBuilder: (context, index) {
            final floor = controller.minFloor.value + index;
            return Obx(() => GestureDetector(
                  onTap: () => controller.selectBuildingFloor(floor),
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: controller.selectedBuildingFloor.value == floor
                          ? Get.theme.primaryColor
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        floor.toString(),
                        style: TextStyle(
                          color: controller.selectedBuildingFloor.value == floor
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
}

class _NumberSelector extends StatelessWidget {
  final RxInt selectedValue;
  final ValueChanged<int> onSelected;
  final RxInt min;
  final RxInt max;

  const _NumberSelector({
    required this.selectedValue,
    required this.onSelected,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _RoomDetails extends StatelessWidget {
  final EditHouseController controller;

  const _RoomDetails({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.specifications.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.specifications.length,
            itemBuilder: (context, index) {
              final specification = controller.specifications[index];
              return _IndividualRoomStepper(
                label: specification.name ?? '',
                value: controller.specificationCounts[specification.id]!,
                onChanged: (change) => controller.changeSpecificationCount(
                    specification.id, change),
              );
            },
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: controller.showRenovationPicker,
            child: AbsorbPointer(
              child: Obx(() => TextFormField(
                    key: Key(controller.selectedRenovation.value ?? ''),
                    initialValue: controller.selectedRenovation.value,
                    decoration: const InputDecoration(
                        labelText: 'Renovation',
                        hintText: 'Select renovation type',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.arrow_drop_down)),
                  )),
            ),
          ),
        ],
      );
    });
  }
}

class _IndividualRoomStepper extends StatelessWidget {
  final String label;
  final RxInt value;
  final Function(int) onChanged;

  const _IndividualRoomStepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _AmenitiesButton extends StatelessWidget {
  final EditHouseController controller;

  const _AmenitiesButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: controller.showAmenitiesPicker,
      icon: const Icon(Icons.add),
      label: const Text('Additional Information'),
      style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50)),
    );
  }
}

class _BottomButtons extends StatelessWidget {
  final EditHouseController controller;

  const _BottomButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: ElevatedButton(
                onPressed: () {},
                child: const Text('Delete'),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red))),
        const SizedBox(width: 16),
        Expanded(
            child: ElevatedButton(
                onPressed: controller.submitListing,
                child: const Text('Update'))),
      ],
    );
  }
}

class _SpheresButton extends StatelessWidget {
  final EditHouseController controller;

  const _SpheresButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.spheres.isEmpty) {
        return const Center(child: Text('No spheres found'));
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.spheres.map((sphere) {
          final isSelected = controller.selectedSpheres.contains(sphere);

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
                controller.selectedSpheres.add(sphere);
              } else {
                controller.selectedSpheres.remove(sphere);
              }
            },
          );
        }).toList(),
      );
    });
  }
}
