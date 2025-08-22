import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/home/models/notifcation_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/house_details_view.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/widgets/custom_app_bar.dart';
import 'package:jaytap/shared/widgets/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final HomeController controller = Get.find<HomeController>();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();

    controller.fetchNotifications();
  }

  void _onRefresh() async {
    await controller.fetchNotifications();

    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await controller.loadMoreNotifications();

    if (controller.hasMoreNotifications.value) {
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _auth = AuthStorage();
    return Scaffold(
      appBar: CustomAppBar(title: 'notifications', showBackButton: true),
      body: (_auth.token == null || _auth.token!.isEmpty)
          ? Center(
              child: Text("No token"),
            )
          : Obx(() {
              if (controller.isLoadingNotifcations.value &&
                  controller.notificationList.isEmpty) {
                return CustomWidgets.loader();
              }

              if (controller.notificationList.isEmpty) {
                return const Center(
                  child: Text(
                    'No notifications yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return SmartRefresher(
                controller: _refreshController,
                enablePullUp: true,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                header: const WaterDropHeader(),
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus? mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = const Text("pull up load");
                    } else if (mode == LoadStatus.loading) {
                      body = CustomWidgets.loader();
                    } else if (mode == LoadStatus.failed) {
                      body = const Text("Load Failed!Click retry!");
                    } else if (mode == LoadStatus.canLoading) {
                      body = const Text("release to load more");
                    } else {
                      body = const Text("No more Data");
                    }
                    return SizedBox(height: 55.0, child: Center(child: body));
                  },
                ),
                child: ListView.builder(
                  itemCount: controller.notificationList.length,
                  itemBuilder: (context, index) {
                    final notification = controller.notificationList[index];
                    return NotificationCard(userNotification: notification);
                  },
                ),
              );
            }),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final UserNotification userNotification;
  const NotificationCard({super.key, required this.userNotification});

  @override
  Widget build(BuildContext context) {
    final notification = userNotification.notification;
    final formattedDate = DateFormat.yMMMd().format(notification.createdAt);

    return GestureDetector(
      onTap: () {
        Get.to(() => HouseDetailsView(
            houseID: notification.product.first, myHouses: false));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  IconlyBold.notification,
                  color: context.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        formattedDate,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
