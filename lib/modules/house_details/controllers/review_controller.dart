import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/modules/house_details/models/comment_model.dart';

class ReviewController extends GetxController {
  final int houseID;
  final List<CommentModel> initialComments;

  ReviewController({required this.houseID, required this.initialComments});

  var comments = <CommentModel>[].obs;
  var isLoading = false.obs;
  late TextEditingController commentController;

  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    comments.assignAll(initialComments);
    commentController = TextEditingController();
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  void saveComment() async {
    if (commentController.text.isEmpty || isLoading.value) return;

    isLoading.value = true;

    try {
      final response = await _apiService.handleApiRequest(
        ApiConstants.baseUrl + 'chat/comment/',
        body: {
          'product_id': houseID,
          'comment': commentController.text,
          'reply_to_id': comments.isNotEmpty ? comments.first.id : null,
        },
        method: 'POST',
        requiresToken: true,
      );

      if (response != null && response is Map<String, dynamic>) {
        final newComment = CommentModel.fromJson(response);
        comments.insert(0, newComment);
        commentController.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }
}
