import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/services/api_constants.dart';

class FeatureChip extends StatelessWidget {
  const FeatureChip({
    Key? key,
    required this.icon,
    required this.label,
    this.imageUrl,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (Get.width / 2) - 21,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            Image.network(
              ApiConstants.imageURL + imageUrl!,
              width: 22,
              height: 22,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(icon, size: 22, color: Colors.grey.shade700),
            )
          else
            Icon(icon, size: 22, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
