import 'package:flutter/material.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';

class RealtorSection extends StatelessWidget {
  final OwnerModel owner;
  const RealtorSection({Key? key, required this.owner}) : super(key: key);

  Widget _buildRatingStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasPartialStar = (rating - fullStars) > 0;

    for (int i = 0; i < 5; i++) {
      IconData iconData;
      if (i < fullStars) {
        iconData = Icons.star;
      } else if (i == fullStars && hasPartialStar) {
        iconData = Icons.star_half;
      } else {
        iconData = Icons.star_border;
      }
      stars.add(Icon(
        iconData,
        color: const Color(0xFFFFC107),
        size: 20,
      ));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  @override
  Widget build(BuildContext context) {
    final double ratingValue =
        double.tryParse(owner.rating?.toString() ?? '0.0') ?? 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(
                owner.imgUrl ?? 'https://i.pravatar.cc/150?img=12',
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    owner.name ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F295B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Rieltor',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    _buildRatingStars(
                        ratingValue), // Yıldızları oluşturan fonksiyon
                    const SizedBox(width: 8),
                    Text(
                      ratingValue
                          .toStringAsFixed(1), // Reytingi "3.2" gibi gösterir
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4F4F4F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Eski kodunuzda telefon numarası için `username` kullanılıyordu.
                Text(
                  owner.username ?? '+9931415263',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
