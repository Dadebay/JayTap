import 'package:flutter/material.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/detail_row.dart';

class PrimaryDetailsSection extends StatelessWidget {
  const PrimaryDetailsSection({Key? key, required this.house}) : super(key: key);
  final PropertyModel house;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bildirişin maglumatlary', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          DetailRow(icon: Icons.home_work_outlined, label: 'Bölümi', value: house.category?.titleTk ?? ''),
          DetailRow(icon: Icons.business_outlined, label: 'Binanyn synpy', value: house.region?.name ?? ''),
          DetailRow(icon: Icons.stairs_outlined, label: 'Binanyn gatnysy', value: house.village?.name ?? ''),
          DetailRow(icon: Icons.aspect_ratio_outlined, label: 'Yeri', value: 'B/B'),
          DetailRow(icon: Icons.square_foot_outlined, label: 'Umumy meýdany', value: '${house.square} m²'),
          // DetailRow(icon: Icons.meeting_room_outlined, label: 'Otag sany',
          //     value: house.specification.map((e) => e.nameTm).join(', ')),
          DetailRow(icon: Icons.build_outlined, label: 'Remont görnüşi', value: house.remont?.map((e) => e.name).join(', ') ?? ''),
          DetailRow(icon: Icons.description_outlined, label: 'Bellik', value: 'Yapylan/Yok'),
        ],
      ),
    );
  }
}
