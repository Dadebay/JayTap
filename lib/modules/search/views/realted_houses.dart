import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/home/components/properties_widget_view.dart';
import 'package:jaytap/shared/widgets/custom_app_bar.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../controllers/realted_houses_controller.dart';

class RealtedHousesView extends StatefulWidget {
  final List<int> propertyIds;

  const RealtedHousesView({super.key, required this.propertyIds});

  @override
  State<RealtedHousesView> createState() => _RealtedHousesViewState();
}

class _RealtedHousesViewState extends State<RealtedHousesView> {
  final RealtedHousesController controller = Get.put(RealtedHousesController());

  @override
  void initState() {
    super.initState();
    controller.fetchPropertiesByIds(isRefresh: false, propertyIds: widget.propertyIds);
  }

  void onRefresh() {
    controller.fetchPropertiesByIds(isRefresh: true, propertyIds: widget.propertyIds);
  }

  void onLoading() {
    controller.fetchPropertiesByIds(isRefresh: false, propertyIds: widget.propertyIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'relatedHouses',
        showBackButton: true,
        actionButton: Obx(() => IconButton(
              icon: Icon(controller.isGridView.value ? IconlyBold.category : Icons.view_list_rounded),
              onPressed: controller.toggleView,
            )),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.properties.isEmpty) {
          return CustomWidgets.loader();
        }

        if (controller.properties.isEmpty) {
          return Center(child: Text("notFoundHouse".tr));
        }

        return SmartRefresher(
          controller: controller.refreshController,
          enablePullUp: true,
          onRefresh: () {
            onRefresh();
          },
          onLoading: () {
            onLoading();
          },
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
          child: PropertiesWidgetView(
            properties: controller.properties,
            isGridView: controller.isGridView.value,
            removePadding: false,
            inContentBanners: const [],
            myHouses: false,
          ),
        );
      }),
    );
  }
}
