// VIEW - realted_houses_view.dart
// ============================================
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/components/properties_widget_view.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/search/controllers/filter_controller.dart';
import 'package:jaytap/modules/search/controllers/search_controller_mine.dart';
import 'package:jaytap/modules/search/views/filter_view.dart';
import 'package:jaytap/shared/widgets/custom_app_bar.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../controllers/realted_houses_controller.dart';

class RealtedHousesView extends StatefulWidget {
  final List<int> propertyIds;
  final VoidCallback? onBack;
  final bool isVisible;

  const RealtedHousesView({
    super.key,
    required this.propertyIds,
    this.onBack,
    this.isVisible = false,
  });

  @override
  State<RealtedHousesView> createState() => _RealtedHousesViewState();
}

class _RealtedHousesViewState extends State<RealtedHousesView>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _scrollController;
  bool _showScrollToTopButton = false;

  @override
  bool get wantKeepAlive => true;

  RealtedHousesController? _controller;
  RealtedHousesController get controller {
    _controller ??= Get.put(
      RealtedHousesController(),
      tag: 'related_houses_controller',
    );
    return _controller!;
  }

  final HomeController homeController = Get.find<HomeController>();
  final FilterController filterController = Get.put(FilterController());

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (mounted) {
          setState(() {
            _showScrollToTopButton = _scrollController.offset >= 400;
          });
        }
      });

    // ✅ İlk yükleme - sadece bir kez
    _loadInitialDataIfNeeded();

    // ✅ Başlangıçta filter durumunu kontrol et
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.checkGlobalFilterState();
      }
    });
  }

  @override
  void didUpdateWidget(RealtedHousesView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ Widget görünür hale geldiğinde
    if (widget.isVisible && !oldWidget.isVisible) {
      print('👀 Widget became visible');
      controller.onBecameVisible();
      controller.checkGlobalFilterState();
      _loadInitialDataIfNeeded();
    }

    // Check if propertyIds changed
    if (widget.propertyIds.length != oldWidget.propertyIds.length ||
        !listEquals(widget.propertyIds, oldWidget.propertyIds)) {
      // ✅ DOUBLE FETCH PREVENTION:
      // If the new IDs match what the controller ALREADY has (e.g. from applyFilter),
      // then Do NOT fetch again.
      if (listEquals(widget.propertyIds, controller.currentPropertyIds)) {
        print(
            '🛑 IDs match current controller state. Skipping redundant fetch.');
        return;
      }

      print('🔄 Property IDs changed, reloading...');
      controller.fetchPropertiesByIds(
        isRefresh: true,
        propertyIds: widget.propertyIds,
      );
    }
  }

  void _loadInitialDataIfNeeded() {
    // ✅ Sadece henüz yüklenmemişse yükle
    if (!controller.isInitialized.value && widget.isVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          print('🚀 Loading initial data');
          controller.fetchPropertiesByIds(
            isRefresh: true,
            propertyIds: widget.propertyIds,
          );
        }
      });
    }
  }

  void onRefresh() {
    print('🔄 onRefresh called');

    // ✅ RefreshController'ı sıfırla
    controller.refreshController.resetNoData();

    // ✅ Filter durumuna göre refresh yap
    if (controller.isFiltered.value) {
      // Eğer bir sort filter varsa (frommin, new, vb.)
      if (controller.currentFilter.value != null &&
          controller.currentFilter.value != 'filter_view') {
        print(
            '🔄 Refreshing with sort filter: ${controller.currentFilter.value}');
        controller.applyFilter(controller.currentFilter.value!,
            isRefresh: true);
      }
      // Eğer detaylı filter varsa (filter_view)
      else if (controller.currentFilter.value == 'filter_view') {
        print('🔄 Refreshing with detailed filter');
        // Detaylı filter için propertyIds zaten güncel olmalı, o yüzden fetchPropertiesByIds çağırıyoruz
        controller.fetchPropertiesByIds(
          isRefresh: true,
          propertyIds: widget.propertyIds,
        );
      } else {
        // Fallback
        controller.fetchPropertiesByIds(
          isRefresh: true,
          propertyIds: widget.propertyIds,
        );
      }
    } else {
      // ✅ Normal ID'lerle yeniden yükle
      print('🔄 Refreshing normal list');
      controller.fetchPropertiesByIds(
        isRefresh: true,
        propertyIds: widget.propertyIds,
      );
    }
  }

  void onLoading() {
    print('⬆️ onLoading called');
    print('🔍 isFiltered: ${controller.isFiltered.value}');
    print('📄 hasNextPage: ${controller.hasNextPage.value}');
    print('⏳ isMoreLoading: ${controller.isMoreLoading.value}');

    // ✅ Eğer zaten yükleme yapılıyorsa işlem yapma
    if (controller.isMoreLoading.value) {
      print('⏳ Already loading more data, ignoring request...');
      return;
    }

    // ✅ 1. URL Based Filter (Sort api)
    if (controller.isFiltered.value && controller.nextPageUrl.value != null) {
      controller.loadMoreFilteredData();
    }
    // ✅ 2. ID Based Filter (Map) OR No Filter (Normal Pagination)
    else if (controller.hasNextPage.value) {
      // Map filter has isFiltered=true but nextPageUrl=null, so it falls here correctly
      controller.fetchPropertiesByIds(
        isRefresh: false,
        propertyIds: widget.propertyIds,
      );
    }
    // ✅ 3. No more data
    else {
      print('🚫 No more data to load');
      controller.refreshController.loadNoData();
    }
  }

  void _showFilterDialog(BuildContext context) {
    String selectedFilter = controller.currentFilter.value ?? 'frommin';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "tertiplemek".tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildRadioOption(
                      value: 'frommin',
                      groupValue: selectedFilter,
                      label: 'frommin'.tr,
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value!;
                        });
                      },
                    ),
                    SizedBox(height: 6),
                    _buildRadioOption(
                      value: 'frommax',
                      groupValue: selectedFilter,
                      label: 'frommax'.tr,
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value!;
                        });
                      },
                    ),
                    SizedBox(height: 6),
                    _buildRadioOption(
                      value: 'new',
                      groupValue: selectedFilter,
                      label: 'fromnew'.tr,
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value!;
                        });
                      },
                    ),
                    SizedBox(height: 6),
                    _buildRadioOption(
                      value: 'old',
                      groupValue: selectedFilter,
                      label: 'fromold'.tr,
                      onChanged: (value) {
                        setState(() {
                          selectedFilter = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final ids = await controller
                              .applyFilter(selectedFilter, isRefresh: true);

                          if (Get.isRegistered<SearchControllerMine>()) {
                            Get.find<SearchControllerMine>()
                                .setFilterData(propertyIds: ids);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'tertiple'.tr,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String groupValue,
    required String label,
    required Function(String?) onChanged,
  }) {
    bool isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Colors.blue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.blue;
                }
                return Colors.grey.shade400;
              }),
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.blue.shade700 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOnMap() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              CustomAppBar(
                leadingButton: Obx(() {
                  if (controller.isFiltered.value) {
                    return IconButton(
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                      icon: Icon(IconlyBold.delete, color: Color(0xffff6242)),
                      onPressed: () {
                        controller.isLoading.value =
                            true; // Show loader immediately
                        controller.resetFilterState();

                        // 1. Reset FilterController if present
                        if (Get.isRegistered<FilterController>()) {
                          filterController.resetFilters();
                        }
                        // 2. Fallback: Reset SearchController directly
                        else if (Get.isRegistered<SearchControllerMine>()) {
                          Get.find<SearchControllerMine>()
                              .setFilterData(); // Reset to all
                        }
                        // 3. Last Result: Use stale IDs (should rarely happen)
                        else {
                          controller.fetchPropertiesByIds(
                              isRefresh: true, propertyIds: widget.propertyIds);
                        }

                        // Clear Map Drawing explicitly
                        if (Get.isRegistered<SearchControllerMine>()) {
                          Get.find<SearchControllerMine>().clearDrawing();
                        }
                      },
                    );
                  }
                  return const SizedBox.shrink();
                }),
                title: 'relatedHouses',
                centerTitle: true,
                showBackButton: true,
                onBack: widget.onBack,
                actionButton: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity:
                          VisualDensity(horizontal: -4, vertical: -4),
                      icon: const Icon(Icons.filter_list),
                      onPressed: () async {
                        final result = await Get.to(() => FilterView());
                        if (result != null && result is List<int>) {
                          controller.isFiltered.value =
                              true; // Set to true when filter is applied
                          controller.currentFilter.value =
                              'filter_view'; // Indicate filter from FilterView
                          controller.fetchPropertiesByIds(
                              isRefresh: true, propertyIds: result);

                          // ✅ Sync with SearchControllerMine
                          if (Get.isRegistered<SearchControllerMine>()) {
                            Get.find<SearchControllerMine>()
                                .setFilterData(propertyIds: result);
                          }
                        }
                      },
                    ),
                    IconButton(
                      visualDensity:
                          VisualDensity(horizontal: -4, vertical: -4),
                      icon: const Icon(IconlyLight.swap),
                      onPressed: () => _showFilterDialog(context),
                    ),
                    Obx(() => IconButton(
                          visualDensity:
                              VisualDensity(horizontal: -4, vertical: -4),
                          icon: Icon(controller.isGridView.value
                              ? IconlyBold.category
                              : Icons.view_list_rounded),
                          onPressed: controller.toggleView,
                        )),
                  ],
                ),
              ),
              Expanded(
                child: SmartRefresher(
                  controller: controller.refreshController,
                  scrollController: _scrollController,
                  enablePullUp: true,
                  enablePullDown: true,
                  onRefresh: onRefresh,
                  onLoading: onLoading,
                  header: WaterDropHeader(),
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus? mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = Text("pull_up_load".tr);
                      } else if (mode == LoadStatus.loading) {
                        body = CustomWidgets.loader();
                      } else if (mode == LoadStatus.failed) {
                        body = Text("load_failed_click_retry".tr);
                      } else if (mode == LoadStatus.canLoading) {
                        body = Text("release_to_load_more".tr);
                      } else {
                        body = Text("no_more_data".tr);
                      }
                      return SizedBox(height: 55.0, child: Center(child: body));
                    },
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.properties.isEmpty) {
                      return ListView(
                        controller: _scrollController, // Attach controller
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Center(child: CustomWidgets.loader()),
                          ),
                        ],
                      );
                    }

                    if (controller.properties.isEmpty) {
                      return ListView(
                        controller: _scrollController, // Attach controller
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: Center(child: Text("notFoundHouse".tr)),
                          ),
                        ],
                      );
                    }

                    return PropertiesWidgetView(
                      properties: controller.properties,
                      isGridView: controller.isGridView.value,
                      removePadding: false,
                      inContentBanners: const [],
                      myHouses: false,
                    );
                  }),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 15.0,
            left: 15,
            child: ElevatedButton(
              onPressed: _showOnMap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffE2F3FC),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0),
                      child: SvgPicture.asset("assets/icons/map.svg"),
                    ),
                  ),
                  Text(
                    'showOnMap'.tr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _showScrollToTopButton == false
          ? null
          : SizedBox(
              height: 46, // 🔥 BURAYI küçülterek yüksekliği kontrol ediyorsun
              width: 50,
              child: FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                backgroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.black87,
                  size: 22, // ikon da küçültüldü
                ),
              ),
            ),
    );
  }
}

// ============================================
// PARENT WIDGET - SearchView için DOĞRU KULLANIM
// ============================================

// SearchView widget'ınızda build metodunu şu şekilde güncelleyin:
