import 'package:jaytap/modules/search/controllers/filter_controller.dart';
import 'package:jaytap/shared/extensions/packages.dart';
import 'package:get/get.dart';

class FilterView extends StatelessWidget {
  const FilterView({super.key});

  @override
  Widget build(BuildContext context) {
    final FilterController controller = Get.put(FilterController());

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close,
                color: Theme.of(context).colorScheme.onBackground),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.resetFilters();
              },
              child: Text(
                'filter_reset'.tr,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 16),
              ),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: _buildBody(controller),
              ),
              _BottomButtons(controller: controller),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBody(FilterController controller) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        Obx(() {
          if (controller.categories.isEmpty) return const SizedBox.shrink();
          return _Section(
            title: 'filter_category'.tr,
            child: _CategorySelector(controller: controller),
          );
        }),
        Obx(() {
          if (controller.subCategories.isEmpty) return const SizedBox.shrink();
          return _Section(
            title: 'filter_subcategory'.tr,
            child: _SubCategorySelector(controller: controller),
          );
        }),
        Obx(() {
          if (controller.subinCategories.isEmpty)
            return const SizedBox.shrink();
          return _Section(
            title: 'filter_sub_in_category'.tr,
            child: _SubInCategorySelector(controller: controller),
          );
        }),
        Obx(() {
          if (controller.villages.isEmpty) return const SizedBox.shrink();
          return _Section(
            title: 'filter_city'.tr,
            child: _CitySelector(controller: controller),
          );
        }),
        Obx(() {
          if (controller.regions.isEmpty) return const SizedBox.shrink();
          return _Section(
            title: 'filter_region'.tr,
            child: _RegionSelector(controller: controller),
          );
        }),
        _Section(
          title: 'filter_number_of_rooms'.tr,
          child: _NumberSelector(
            selectedValues: controller.totalRoomCount,
            onSelected: controller.toggleRoomCount,
            min: controller.minRoom,
            max: controller.maxRoom,
          ),
        ),
        _Section(
          title: 'filter_total_floors'.tr,
          child: _NumberSelector(
            selectedValues: controller.totalFloorCount,
            onSelected: controller.toggleTotalFloor,
            min: controller.minFloor,
            max: controller.maxFloor,
          ),
        ),
        _Section(
          title: 'filter_floor'.tr,
          child: _FloorSelector(controller: controller),
        ),
        _RenovationSection(controller: controller),
        _AreaSection(controller: controller),
        _Section(
          title: 'filter_price_range'.tr,
          child: Row(
            children: [
              Expanded(
                child: _TextField(
                  controller: controller.minPriceController,
                  hint: 'filter_min_price'.tr,
                  suffix: 'TMT',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _TextField(
                  controller: controller.maxPriceController,
                  hint: 'filter_max_price'.tr,
                  suffix: 'TMT',
                ),
              ),
            ],
          ),
        ),
        _SellerTypeSection(controller: controller),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SellerTypeSection extends StatelessWidget {
  final FilterController controller;
  const _SellerTypeSection({required this.controller});
  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'filter_seller'.tr,
      child: Obx(() => Row(
            children: [
              Expanded(
                child: SelectorItem(
                    label: 'filter_owner'.tr,
                    isSelected: controller.sellerType.value == 'Eýesi',
                    onTap: () => controller.selectSellerType(
                          'Eýesi',
                        )),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SelectorItem(
                  label: 'filter_realtor'.tr,
                  isSelected: controller.sellerType.value == 'Reiltor',
                  onTap: () => controller.selectSellerType('Reiltor'),
                ),
              ),
            ],
          )),
    );
  }
}

class _RenovationSection extends StatelessWidget {
  final FilterController controller;
  const _RenovationSection({required this.controller});
  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'filter_renovation'.tr,
      child: GestureDetector(
        onTap: controller.showRenovationPicker,
        child: AbsorbPointer(
          child: Obx(() => TextFormField(
                key: Key(controller.selectedRenovation.value ?? ''),
                initialValue: controller.selectedRenovation.value,
                decoration: InputDecoration(
                  hintText: 'filter_select_renovation'.tr,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                ),
              )),
        ),
      ),
    );
  }
}

class _AreaSection extends StatelessWidget {
  final FilterController controller;
  const _AreaSection({required this.controller});
  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'filter_total_area'.tr,
      child: Obx(() => Column(
            children: [
              RangeSlider(
                values: controller.selectedAreaRange.value,
                min: 0,
                max: 1000,
                divisions: 100,
                activeColor: Theme.of(context).colorScheme.primary,
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
                      hint: 'filter_min'.tr,
                      suffix: 'm²',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _TextField(
                      controller: controller.maxAreaController,
                      hint: 'filter_max'.tr,
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
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
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
        hintStyle:
            TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        suffixText: suffix,
        prefixText: prefix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.shadow),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      ),
    );
  }
}

class SelectorItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const SelectorItem(
      {required this.label,
      required this.isSelected,
      required this.onTap,
      super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
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
          return const SizedBox.shrink();
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.villages.length,
          itemBuilder: (context, index) {
            final village = controller.villages[index];
            return Obx(() => SelectorItem(
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
          return const SizedBox.shrink();
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.regions.length,
          itemBuilder: (context, index) {
            final region = controller.regions[index];
            return Obx(() => SelectorItem(
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
    return Obx(() {
      if (controller.categories.isEmpty) {
        return const SizedBox.shrink();
      }
      return Row(
        children: controller.categories.map((category) {
          return Expanded(
            child: Obx(() => SelectorItem(
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
            return Obx(() => SelectorItem(
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
            return Obx(() => SelectorItem(
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
        height: 45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: (controller.maxFloor.value ?? 0) -
              (controller.minFloor.value ?? 0) +
              1,
          itemBuilder: (context, index) {
            final floor = controller.minFloor.value! + index;
            return Obx(() => SelectorItem(
                  label: floor.toString(),
                  isSelected: controller.selectedBuildingFloor.contains(floor),
                  onTap: () => controller.toggleBuildingFloor(floor),
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
      final int actualMin = min.value ?? 0;
      final int actualMax = max.value ?? 0;

      if (actualMin == 0 && actualMax == 0) {
        return const Center(child: CircularProgressIndicator());
      }
      return SizedBox(
        height: 45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: actualMax - actualMin + 1,
          itemBuilder: (context, index) {
            final number = actualMin + index;
            return Obx(() => SelectorItem(
                  label: number.toString(),
                  isSelected: selectedValues.contains(number),
                  onTap: () => onSelected(number),
                ));
          },
        ),
      );
    });
  }
}

class _BottomButtons extends StatelessWidget {
  final FilterController controller;
  const _BottomButtons({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
              top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
            )
          ]),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: controller.applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('filter_search'.tr),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: controller.showSaveFilterDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('save'.tr),
            ),
          ),
        ],
      ),
    );
  }
}
