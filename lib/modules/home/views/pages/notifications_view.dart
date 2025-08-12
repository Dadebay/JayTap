import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/shared/widgets/custom_app_bar.dart';

class NotificationsView extends GetView {
  const NotificationsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'notifications', showBackButton: true),
      body: const Center(
        child: Text(
          'NotificationsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
