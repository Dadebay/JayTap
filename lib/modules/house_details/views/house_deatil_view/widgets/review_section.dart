import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:jaytap/core/services/api_service.dart';
import 'package:jaytap/core/services/api_constants.dart';
import 'package:jaytap/core/services/auth_storage.dart';
import 'package:jaytap/modules/auth/views/login_view.dart';
import 'package:jaytap/modules/house_details/models/comment_model.dart';

class ReviewSection extends StatefulWidget {
  final int houseID;
  final List<CommentModel> comments;
  const ReviewSection({Key? key, required this.houseID, required this.comments}) : super(key: key);

  @override
  State<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSection> {
  final TextEditingController _commentController = TextEditingController();
  late List<CommentModel> _comments;
  final AuthStorage _authStorage = Get.put(AuthStorage());
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _comments = widget.comments;
  }

  void _saveComment() async {
    if (_commentController.text.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.handleApiRequest(
        ApiConstants.baseUrl + 'chat/comment/',
        body: {
          'product_id': widget.houseID,
          'comment': _commentController.text,
          'reply_to_id': _comments.isNotEmpty ? _comments.last.id : null,
        },
        method: 'POST',
        requiresToken: true,
      );

      if (response != null) {}
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Teswirler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.expand_less),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_authStorage.isLoggedIn)
            SizedBox(
              height: 300,
              child: Column(
                children: [
                  Expanded(
                    child: _comments.isEmpty
                        ? Center(
                            child: Text(
                              'Entäk teswir ýok',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: const Color.fromARGB(255, 84, 76, 76).withOpacity(0.65)),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundImage: NetworkImage(comment.user.img ?? ''),
                                          backgroundColor: Colors.grey[200],
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          comment.user.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      comment.comment,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        comment.createdAt.toLocal().toString().split('.')[0],
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16), // Liste ile TextField arası boşluk

                  SizedBox(
                    height: 48,
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        hintText: 'Teswir ýazyň...',
                        suffixIcon: IconButton(
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(IconlyLight.send, color: Colors.blue),
                          onPressed: _saveComment,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
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
                        side: const BorderSide(color: Color(0xFF0D99FF), width: 1.5),
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
