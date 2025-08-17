import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:jaytap/modules/home/controllers/home_controller.dart';
import 'package:jaytap/modules/home/models/notifcation_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/house_details_view.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:jaytap/shared/widgets/custom_app_bar.dart';
import 'package:jaytap/shared/widgets/widgets.dart';

class NotificationsView extends GetView<HomeController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'notifications', showBackButton: true),
      body: Obx(() {
        if (controller.isLoadingNotifcations.value) {
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

        return ListView.builder(
          itemCount: controller.notificationList.length,
          itemBuilder: (context, index) {
            final notification = controller.notificationList[index];
            return NotificationCard(userNotification: notification);
          },
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
        Get.to(() => HouseDetailsView(houseID: notification.product.first));
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
