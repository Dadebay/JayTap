import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDialogs {
  static void showSaveFilterDialog({
    required BuildContext context,
    required Function(String) onSave,
  }) {
    final TextEditingController nameController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(
          'dialog_save_filter_title'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'dialog_save_filter_hint'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'dialog_cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                onSave(nameController.text);
              } else {
                showErrorSnackbar(
                  title: 'snackbar_error'.tr,
                  message: 'snackbar_filter_name_error'.tr,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: Text(
              'dialog_save'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  static void showSuccessSnackbar({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      borderRadius: 12.0,
      margin: const EdgeInsets.all(16.0),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    );
  }

  static void showErrorSnackbar({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      borderRadius: 12.0,
      margin: const EdgeInsets.all(16.0),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
