import 'package:flutter/material.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/detail_row.dart';

class PrimaryDetailsSection extends StatelessWidget {
  const PrimaryDetailsSection({Key? key, required this.house})
      : super(key: key);
  final PropertyModel house;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bildirişin maglumatlary',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          DetailRow(
              icon: Icons.home_work_outlined,
              label: 'Bölümi',
              value: house.category?.titleTk ?? ''),
          DetailRow(
              icon: Icons.stairs_outlined,
              label: 'Welaýaty',
              value: house.village?.name ?? ''),
          DetailRow(
              icon: Icons.business_outlined,
              label: 'Şäheri',
              value: house.region?.name ?? ''),

          DetailRow(
              icon: Icons.aspect_ratio_outlined, label: 'Yeri', value: 'B/B'),
          DetailRow(
              icon: Icons.square_foot_outlined,
              label: 'Umumy meýdany',
              value: '${house.square} m²'),
          DetailRow(
              icon: Icons.meeting_room_outlined,
              label: 'Otag sany',
              value: house.roomcount?.toString() ?? ''),
          DetailRow(
              icon: Icons.layers_outlined,
              label: 'Gaty',
              value: house.floorcount?.toString() ?? ''),
          DetailRow(
              icon: Icons.attach_money_outlined,
              label: 'Bahasy',
              value: '${house.price} TMT'),
          DetailRow(
              icon: Icons.remove_red_eye_outlined,
              label: 'Görülen sany',
              value: house.viewcount?.toString() ?? ''),

          DetailRow(
              icon: Icons.phone_outlined,
              label: 'Telefon belgi',
              value: house.phoneNumber ?? ''),
          // DetailRow(icon: Icons.meeting_room_outlined, label: 'Otag sany',
          //     value: house.specification.map((e) => e.nameTm).join(', ')),
          DetailRow(
              icon: Icons.build_outlined,
              label: 'Remont görnüşi',
              value: house.remont?.map((e) => e.name).join(', ') ?? ''),
          if (house.specifications != null && house.specifications!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text('Aýratynlyklary',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                ...house.specifications!
                    .map((spec) => DetailRow(
                          icon: Icons.check_box_outlined,
                          label: spec.spec.name ?? '',
                          value: spec.count.toString(),
                        ))
                    .toList(),
              ],
            ),
          if (house.sphere != null && house.sphere!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text('Ýakyn ýerleri',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                ...house.sphere!
                    .map((s) => DetailRow(
                          icon: Icons.location_on_outlined,
                          label: s.name ?? '',
                          value:
                              '', // No specific value for sphere, just the name
                        ))
                    .toList(),
              ],
            ),
          DetailRow(
              icon: Icons.description_outlined,
              label: 'Bellik',
              value: 'Yapylan/Yok'),
        ],
      ),
    );
  }
}
