import 'package:flutter/material.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';

class RealtorSection extends StatelessWidget {
  final OwnerModel owner;
  const RealtorSection({Key? key, required this.owner}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
                owner.imgUrl ?? 'https://i.pravatar.cc/150?img=12'),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(owner.name ?? 'N/A',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 36, 39, 96))),
              const Text(
                  'Rieltor', 
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 84, 76, 76))),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Row(
              //   children: List.generate(
              //     5,
              //     (index) {
              //       double rating =
              //           double.tryParse(owner.rating ?? '0.0') ?? 0.0;
              //       return Icon(
              //         index < rating ? Icons.star : Icons.star_border,
              //         color: Colors.amber,
              //         size: 18,
              //       );
              //     },
              //   ),
              // ),
              Text(owner.name ?? 'N/A',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 84, 76, 76))),
            ],
          ),
        ],
      ),
    );
  }
}
