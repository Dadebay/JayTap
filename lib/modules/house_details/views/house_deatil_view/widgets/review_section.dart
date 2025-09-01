import 'package:intl/intl.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/auth/views/login_view.dart';
import 'package:jaytap/modules/house_details/controllers/review_controller.dart';
import 'package:jaytap/modules/house_details/models/comment_model.dart';
import 'package:jaytap/shared/extensions/packages.dart';

class ReviewSection extends StatefulWidget {
  final int houseID;
  final List<CommentModel> comments;

  const ReviewSection({Key? key, required this.houseID, required this.comments})
      : super(key: key);

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final ReviewController controller = Get.put(
      ReviewController(
          houseID: widget.houseID, initialComments: widget.comments),
      tag: widget.houseID.toString(),
    );
    final AuthStorage authStorage = Get.put(AuthStorage());

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.4) // Use onSurface for shadow in dark mode
                : Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'section_13'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  size: 28,
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              children: [
                if (_isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: authStorage.isLoggedIn
                        ? _buildCommentsSection(controller)
                        : _buildLoginPrompt(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Giriş yapıldığında gösterilecek widget
  Widget _buildCommentsSection(ReviewController controller) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 250),
          child: Obx(() {
            if (controller.comments.isEmpty) {
              return Center(
                heightFactor: 3,
                child: Text('no_reviews_yet'.tr,
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7))),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: controller.comments.length,
              itemBuilder: (context, index) =>
                  CommentItem(comment: controller.comments[index]),
            );
          }),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller.commentController,
          style: TextStyle(
              fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            hintText: 'section_15'.tr,
            suffixIcon: Obx(() => IconButton(
                  icon: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(IconlyLight.send,
                          color: Theme.of(context).colorScheme.primary),
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.saveComment,
                )),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.outline)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.outline)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'section_14'.tr,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () {
              // CustomWidgets.showSnackBar('login_button', 'section_14', Colors.red);
              Get.to(() => LoginView());
            },
            child: Text('have_account'.tr,
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          )
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
        DateFormat('dd.MM.yy HH:mm').format(comment.createdAt);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                comment.user.name ?? 'anonymous'.tr,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              Text(formattedDate,
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Text(comment.comment ?? '',
              style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4)),
        ],
      ),
    );
  }
}
