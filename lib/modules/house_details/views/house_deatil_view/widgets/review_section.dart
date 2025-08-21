import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/auth/views/login_view.dart';
import 'package:jaytap/modules/house_details/controllers/review_controller.dart';
import 'package:jaytap/modules/house_details/models/comment_model.dart';

class ReviewSection extends StatelessWidget {
  final int houseID;
  final List<CommentModel> comments;

  const ReviewSection({Key? key, required this.houseID, required this.comments})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReviewController controller = Get.put(
      ReviewController(houseID: houseID, initialComments: comments),
      tag: houseID.toString(),
    );
    final AuthStorage authStorage = Get.put(AuthStorage());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Teswirler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.expand_less),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (authStorage.isLoggedIn)
            SizedBox(
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      if (controller.comments.isEmpty) {
                        return Center(
                          child: Text(
                            'Entäk teswir ýok',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromARGB(255, 84, 76, 76)
                                    .withOpacity(0.65)),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: controller.comments.length,
                        itemBuilder: (context, index) {
                          final comment = controller.comments[index];
                          return CommentItem(comment: comment);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: TextField(
                      controller: controller.commentController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        hintText: 'Teswir ýazyň...',
                        suffixIcon: Obx(() {
                          // Butonu Obx ile sarmala
                          return IconButton(
                            icon: controller.isLoading.value
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(IconlyLight.send,
                                    color: Colors.blue),
                            onPressed: controller.saveComment,
                          );
                        }),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Center(
              child: TextButton(
                onPressed: () {
                  showAuthDialog(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0D99FF),
                ),
                child: const Text(
                  'Teswir ýazmak üçin agza boluň!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  final CommentModel comment;

  const CommentItem({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormat('dd.MM.yyyy, HH:mm').format(comment.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.user.name ?? '',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            comment.comment ?? '',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Icon(
                HugeIcons.strokeRoundedMessage01,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showAuthDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 5,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const HugeIcon(
                icon: HugeIcons.strokeRoundedLogin02,
                size: 56,
                color: Color(0xFF0D99FF),
              ),
              const SizedBox(height: 24.0),
              const Text(
                'Bu amaly ýerine ýetirmek üçin ilki bilen ulgama giriň ýa-da agza boluň',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Color(0xFF4F4F4F),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Get.to(() => LoginView());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D99FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ulgama gir',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Get.to(() => LoginView());
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                            color: Color(0xFF0D99FF), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Agza bol',
                        style: TextStyle(
                          color: Color(0xFF0D99FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
