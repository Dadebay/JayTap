import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/search/controllers/filter_controller.dart';

class FilterView extends StatelessWidget {
  const FilterView({super.key});

  @override
  Widget build(BuildContext context) {
    final FilterController controller = Get.put(FilterController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
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

  Widget _buildBody(FilterController controller) {
    return Column(
      children: [
        Expanded(
          child: ListView(
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
              _Section(
                title: 'Number of Rooms',
                child: _NumberSelector(
                  selectedValues: controller.totalRoomCount,
                  onSelected: controller.toggleRoomCount,
                  min: controller.minRoom,
                  max: controller.maxRoom,
                ),
              ),
              _Section(
                title: 'Total Floors',
                child: _NumberSelector(
                  selectedValues: controller.totalFloorCount,
                  onSelected: controller.toggleTotalFloor,
                  min: controller.minFloor,
                  max: controller.maxFloor,
                ),
              ),
              _Section(
                title: 'Floor',
                child: _FloorSelector(controller: controller),
              ),
              _RenovationSection(controller: controller),
              _AreaSection(controller: controller),
              _Section(
                title: 'Price Range',
                child: Row(
                  children: [
                    Expanded(
                      child: _TextField(
                        controller: controller.minPriceController,
                        hint: 'Min Price',
                        suffix: 'TMT',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _TextField(
                        controller: controller.maxPriceController,
                        hint: 'Max Price',
                        suffix: 'TMT',
                      ),
                    ),
                  ],
                ),
              ),
              _SellerTypeSection(controller: controller), // New Seller Type Section
            ],
          ),
        ),
        _BottomButtons(controller: controller),
      ],
    );
  }
}

// --- NEW SELLER TYPE SECTION WIDGET ---
class _SellerTypeSection extends StatelessWidget {
  final FilterController controller;

  const _SellerTypeSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Kim satýar',
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _SelectorItem(
                    label: 'Eýesi',
                    isSelected: controller.sellerType.value == 'Eýesi',
                    onTap: () => controller.selectSellerType(
                          'Eýesi',
                        )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SelectorItem(
                  label: 'Reiltor',
                  isSelected: controller.sellerType.value == 'Reiltor',
                  onTap: () => controller.selectSellerType('Reiltor'),
                ),
              ),
            ],
          )),
    );
  }
}

// --- NEW RENOVATION SECTION WIDGET ---
class _RenovationSection extends StatelessWidget {
  final FilterController controller;

  const _RenovationSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Renovation',
      child: GestureDetector(
        onTap: controller.showRenovationPicker,
        child: AbsorbPointer(
          child: Obx(() => TextFormField(
                key: Key(controller.selectedRenovation.value ?? ''),
                initialValue: controller.selectedRenovation.value,
                decoration: const InputDecoration(
                  hintText: 'Select renovation type',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              )),
        ),
      ),
    );
  }
}

// --- NEW AREA SECTION WIDGET ---
class _AreaSection extends StatelessWidget {
  final FilterController controller;

  const _AreaSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Umumy meýdany',
      child: Obx(() => Column(
            children: [
              RangeSlider(
                values: controller.selectedAreaRange.value,
                min: 0,
                max: 1000,
                divisions: 100,
                activeColor: Colors.blue,
                labels: RangeLabels(
                  controller.selectedAreaRange.value.start.round().toString(),
                  controller.selectedAreaRange.value.end.round().toString(),
                ),
                onChanged: (RangeValues values) {
                  controller.updateAreaRange(values);
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: _TextField(
                      controller: controller.minAreaController,
                      hint: 'Min',
                      suffix: 'm²',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TextField(
                      controller: controller.maxAreaController,
                      hint: 'Max',
                      suffix: 'm²',
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}

// --- SHARED WIDGETS (Adapted for FilterController) ---

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
      keyboardType: TextInputType.number,
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
          color: isSelected ? Get.theme.primaryColor.withOpacity(0.2) : Colors.white,
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
  final FilterController controller;

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
  final FilterController controller;

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
  final FilterController controller;

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
                  isSelected: controller.selectedCategoryId.value == category.id,
                  onTap: () => controller.selectCategory(category.id),
                ));
          },
        );
      }),
    );
  }
}

class _SubCategorySelector extends StatelessWidget {
  final FilterController controller;

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
                  isSelected: controller.selectedSubCategoryId.value == subCategory.id,
                  onTap: () => controller.selectSubCategory(subCategory.id!),
                ));
          },
        ),
      );
    });
  }
}

class _SubInCategorySelector extends StatelessWidget {
  final FilterController controller;

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
                  isSelected: controller.selectedInSubCategoryId.value == subCategory.id,
                  onTap: () => controller.selectSubIncategory(subCategory.id!),
                ));
          },
        ),
      );
    });
  }
}

class _FloorSelector extends StatelessWidget {
  final FilterController controller;

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
          itemCount: (controller.maxFloor.value ?? 0) - (controller.minFloor.value ?? 0) + 1,
          itemBuilder: (context, index) {
            final floor = controller.minFloor.value! + index;
            return Obx(() => GestureDetector(
                  onTap: () => controller.toggleBuildingFloor(floor),
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: controller.selectedBuildingFloor.contains(floor) ? Get.theme.primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        floor.toString(),
                        style: TextStyle(
                          color: controller.selectedBuildingFloor.contains(floor) ? Colors.white : Colors.black,
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
  final RxList<int> selectedValues;
  final ValueChanged<int> onSelected;
  final Rxn<int> min;
  final Rxn<int> max;

  const _NumberSelector({
    required this.selectedValues,
    required this.onSelected,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Handle null min/max values
      final int actualMin = min.value ?? 0;
      final int actualMax = max.value ?? 0;

      if (actualMin == 0 && actualMax == 0) {
        return const Center(child: CircularProgressIndicator());
      }
      return SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: actualMax - actualMin + 1,
          itemBuilder: (context, index) {
            final number = actualMin + index;
            return Obx(() => GestureDetector(
                  onTap: () => onSelected(number),
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: selectedValues.contains(number) ? Get.theme.primaryColor : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        number.toString(),
                        style: TextStyle(
                          color: selectedValues.contains(number) ? Colors.white : Colors.black,
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

class RoomDetails extends StatelessWidget {
  final FilterController controller;

  const RoomDetails({required this.controller});

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
                onChanged: (change) => controller.changeSpecificationCount(specification.id, change),
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
                    decoration: const InputDecoration(labelText: 'Renovation', hintText: 'Select renovation type', border: OutlineInputBorder(), suffixIcon: Icon(Icons.arrow_drop_down)),
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
              IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => onChanged(-1)),
              Obx(() => Text(value.value.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => onChanged(1)),
            ],
          )
        ],
      ),
    );
  }
}

class _AmenitiesButton extends StatelessWidget {
  final FilterController controller;

  const _AmenitiesButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: controller.showAmenitiesPicker,
      icon: const Icon(Icons.add),
      label: const Text('Additional Information'),
      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
    );
  }
}

class _BottomButtons extends StatelessWidget {
  final FilterController controller;

  const _BottomButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: controller.applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 67, 160, 217),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.shade200),
                ),
              ),
              child: const Text('Gozle'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.showSaveFilterDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 85, 198, 106),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Sakla'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpheresButton extends StatelessWidget {
  final FilterController controller;

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
