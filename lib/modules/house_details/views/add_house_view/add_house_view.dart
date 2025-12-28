// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/modules/house_details/controllers/add_house_controller.dart';
import 'package:latlong2/latlong.dart';
import '../../../../shared/extensions/packages.dart';

class AddHouseView extends StatelessWidget {
  AddHouseView({super.key});
  final AddHouseController controller = Get.put(AddHouseController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(IconlyLight.arrowLeftCircle,
              color: Theme.of(context).colorScheme.onBackground),
        ),
        title: Obx(() => Text(controller.isEditMode.value
            ? 'edit_house_title'.tr
            : 'add_house_title'.tr)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        return _buildBody(controller);
      }),
    );
  }

  Widget _buildBody(AddHouseController controller) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _Section(
          title: 'category_section_title'.tr,
          child: _CategorySelector(controller: controller),
        ),
        _Section(
          title: 'subcategory_section_title'.tr,
          child: _SubCategorySelector(controller: controller),
        ),
        _Section(
          title: 'sub_in_category_section_title'.tr,
          child: _SubInCategorySelector(controller: controller),
        ),
        _Section(
          title: 'region_section_title'.tr,
          child: _CitySelector(controller: controller),
        ),
        _Section(
          title: 'city_section_title'.tr,
          child: _RegionSelector(controller: controller),
        ),
        _Section(
            title: 'map_section_title'.tr, child: _Map(controller: controller)),
        _Section(
          title: 'description_section_title'.tr,
          child: _TextField(
            controller: controller.descriptionController,
            hint: 'description_textfield_hint'.tr,
            maxLines: 5,
          ),
        ),
        _Section(
            title: 'images_section_title'.tr,
            child: _ImagePicker(controller: controller)),
        _Section(
          title: 'area_section_title'.tr,
          child: _TextField(
            controller: controller.areaController,
            hint: 'area_textfield_hint'.tr,
            suffix: 'm²',
            icon: HugeIcons.strokeRoundedRuler,
            keyboardType: TextInputType.number,
          ),
        ),
        _Section(
          title: 'rooms_section_title'.tr,
          child: _NumberSelector(
            selectedValue: controller.totalRoomCount,
            onSelected: (value) => controller.totalRoomCount.value = value,
            min: controller.minRoom,
            max: controller.maxRoom,
          ),
        ),
        _Section(
          title: 'total_floors_section_title'.tr,
          child: _NumberSelector(
            selectedValue: controller.totalFloorCount,
            onSelected: (value) => controller.totalFloorCount.value = value,
            min: controller.minFloor,
            max: controller.maxFloor,
          ),
        ),
        _Section(
          title: 'floor_section_title'.tr,
          child: _FloorSelector(controller: controller),
        ),
        _Section(
          title: 'specifications_section_title'.tr,
          child: _RoomDetails(controller: controller),
        ),
        _Section(
          title: 'price_section_title'.tr,
          child: _TextField(
            controller: controller.priceController,
            hint: 'price_textfield_hint'.tr,
            suffix: 'TMT',
            keyboardType: TextInputType.number,
          ),
        ),
        _Section(
          title: 'additional_info_section_title'.tr,
          child: _AmenitiesButton(controller: controller),
        ),
        _Section(
          title: 'phone_section_title'.tr,
          child: _TextField(
            controller: controller.phoneController,
            hint: 'phone_textfield_hint'.tr,
            prefix: '+993 ',
            icon: HugeIcons.strokeRoundedCall,
            keyboardType: TextInputType.phone,
            maxLength: 8,
          ),
        ),
        _Section(
            title: 'environment_section_title'.tr,
            child: _SpheresButton(controller: controller)),
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
        Text(title,
            style: Get.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
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
  final IconData? icon;
  final TextInputType? keyboardType;
  final int? maxLength;

  const _TextField({
    required this.controller,
    required this.hint,
    this.suffix,
    this.prefix,
    this.maxLines = 1,
    this.icon,
    this.keyboardType,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        prefixText: prefix,
        suffixText: suffix,
        prefixIcon: icon != null
            ? Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 1.0,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
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
    return label.isEmpty
        ? SizedBox.shrink()
        : GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
  }
}

class _CitySelector extends StatelessWidget {
  final AddHouseController controller;

  const _CitySelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Obx(() {
        if (controller.villages.isEmpty) {
          return Center(child: Text('no_cities_found'.tr));
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
  final AddHouseController controller;

  const _RegionSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Obx(() {
        if (controller.regions.isEmpty) {
          return Center(child: Text('no_regions_found'.tr));
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
  final AddHouseController controller;

  const _CategorySelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.categories.isEmpty) {
        return Center(child: Text('no_categories_found'.tr));
      }
      return Row(
        children: controller.categories.map((category) {
          return Expanded(
            child: Obx(() => _SelectorItem(
                  label: category.name ?? '',
                  isSelected:
                      controller.selectedCategoryId.value == category.id,
                  onTap: () => controller.selectCategory(category.id),
                )),
          );
        }).toList(),
      );
    });
  }
}

class _SubCategorySelector extends StatelessWidget {
  final AddHouseController controller;

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
  final AddHouseController controller;

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
  final AddHouseController controller;

  const _Map({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: LatLng(37.95, 58.38),
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: ApiConstants.mapUrl,
                  maxZoom: 18,
                  minZoom: 5,
                  keepBuffer: 8,
                  panBuffer: 2,
                  userAgentPackageName: 'com.gurbanov.jaytap',
                  errorTileCallback: (tile, error, stackTrace) {},
                ),
                Obx(() {
                  if (controller.selectedLocation.value != null) {
                    return MarkerLayer(
                      markers: [
                        Marker(
                          point: controller.selectedLocation.value!,
                          width: 40,
                          height: 40,
                          child: Icon(
                            IconlyBold.location,
                            color: Theme.of(context)
                                .colorScheme
                                .primary, // Use primary color for marker
                            size: 32,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowExpand,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant, // Use onSurfaceVariant for icon color
                ),
                onPressed: controller.openFullScreenMap,
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surface, // Use surface for background color
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
  final AddHouseController controller;

  const _ImagePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: controller.pickImages,
          icon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              IconlyLight.image2,
              size: 40,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant, // Use onSurfaceVariant for icon color
            ),
          ),
          label: Text(
            'pick_images_button'.tr,
            style: TextStyle(
                fontSize: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface), // Use onSurface for text color
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Theme.of(context)
                .colorScheme
                .surfaceVariant, // Use surfaceVariant for background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (controller.images.isEmpty) {
            return Center(
              child: Text(
                'no_images_selected'.tr,
                style: Get.textTheme.bodySmall,
              ),
            );
          }
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
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.54),
                                shape: BoxShape
                                    .circle), // Use onSurface with opacity for background
                            child: Icon(Icons.close,
                                color: Theme.of(context).colorScheme.surface,
                                size: 18), // Use surface for icon color
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
  final AddHouseController controller;

  const _FloorSelector({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.minFloor.value == 0 && controller.maxFloor.value == 0) {
        return const Center(child: CircularProgressIndicator.adaptive());
      }
      return SizedBox(
        height: 45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.maxFloor.value - controller.minFloor.value + 1,
          itemBuilder: (context, index) {
            final floor = controller.minFloor.value + index;
            return Obx(() => _SelectorItem(
                  label: floor.toString(),
                  isSelected: controller.selectedBuildingFloor.value == floor,
                  onTap: () => controller.selectBuildingFloor(floor),
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
        return const Center(child: CircularProgressIndicator.adaptive());
      }
      return SizedBox(
        height: 45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: max.value - min.value + 1,
          itemBuilder: (context, index) {
            final number = min.value + index;
            return Obx(() => _SelectorItem(
                  label: number.toString(),
                  isSelected: selectedValue.value == number,
                  onTap: () => onSelected(number),
                ));
          },
        ),
      );
    });
  }
}

class _RoomDetails extends StatelessWidget {
  final AddHouseController controller;

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
                    decoration: InputDecoration(
                      hintText: 'select_renovation_button'.tr,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 14.0),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
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
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface)),
          Row(
            children: [
              IconButton(
                onPressed: () => onChanged(-1),
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "-",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              Obx(() => Text(
                    value.value.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )),
              IconButton(
                onPressed: () => onChanged(1),
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "+",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _AmenitiesButton extends StatelessWidget {
  final AddHouseController controller;

  const _AmenitiesButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasSelectedAmenities = controller.selectedAmenities.isNotEmpty;
      final amenitiesText = hasSelectedAmenities
          ? 'amenities_list_added'.trParams({
              'amenities': controller.selectedAmenities
                  .map((e) => e.localizedName ?? '')
                  .join(', ')
            })
          : 'add_amenities_button'.tr;

      return OutlinedButton.icon(
        onPressed: controller.showAmenitiesPicker,
        label: Text(amenitiesText),
        style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            )),
      );
    });
  }
}

class _BottomButtons extends StatelessWidget {
  final AddHouseController controller;

  const _BottomButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      child: Obx(() => ElevatedButton.icon(
            onPressed: () {
              final price =
                  double.tryParse(controller.priceController.text) ?? 0.0;
              final area =
                  double.tryParse(controller.areaController.text) ?? 0.0;
              if (controller.images.length < 3) {
                CustomWidgets.showSnackBar('notification'.tr,
                    'error_select_photo'.tr, Colors.red.shade400);
              } else if (price == 0.0) {
                CustomWidgets.showSnackBar('notification'.tr,
                    'error_price_zero'.tr, Colors.red.shade400);
              } else if (area == 0.0) {
                CustomWidgets.showSnackBar('notification'.tr,
                    'error_area_empty'.tr, Colors.red.shade400);
              } else if (controller.phoneController.text.isEmpty) {
                CustomWidgets.showSnackBar('notification'.tr,
                    'error_phone_empty'.tr, Colors.red.shade400);
              } else if (controller.selectedLocation.value == null) {
                CustomWidgets.showSnackBar('notification'.tr,
                    'error_location_empty'.tr, Colors.red.shade400);
              } else if (controller.descriptionController.text.isEmpty) {
                CustomWidgets.showSnackBar('notification'.tr,
                    'error_description_empty'.tr, Colors.red.shade400);
              } else {
                controller.submitListing();
              }
            },
            icon: const SizedBox.shrink(),
            label: Text(controller.isEditMode.value
                ? 'update_listing_button'.tr
                : 'add_listing_button'.tr),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )),
    );
  }
}

class _SpheresButton extends StatelessWidget {
  final AddHouseController controller;

  const _SpheresButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.spheres.isEmpty) {
        return Center(child: Text('no_spheres_found'.tr));
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
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            selected: isSelected,
            selectedColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide.none,
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
