import 'package:flutter/material.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/detail_row.dart';

class PrimaryDetailsSection extends StatelessWidget {
  const PrimaryDetailsSection({Key? key, required this.house})
      : super(key: key);
  final PropertyModel house;

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    String? value,
  }) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return DetailRow(icon: icon, label: label, value: value);
  }

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
          _buildDetailRow(
            icon: Icons.home_work_outlined,
            label: 'Bölümi',
            value: house.category?.titleTk,
          ),
          _buildDetailRow(
            icon: Icons.stairs_outlined,
            label: 'Welaýaty',
            value: house.village?.name,
          ),
          _buildDetailRow(
            icon: Icons.business_outlined,
            label: 'Şäheri',
            value: house.region?.name,
          ),
          _buildDetailRow(
            icon: Icons.aspect_ratio_outlined,
            label: 'Ýeri',
            value: 'B/B',
          ),
          _buildDetailRow(
            icon: Icons.square_foot_outlined,
            label: 'Umumy meýdany',
            value: house.square != null ? '${house.square} m²' : null,
          ),
          _buildDetailRow(
            icon: Icons.meeting_room_outlined,
            label: 'Otag sany',
            value: house.roomcount?.toString(),
          ),
          _buildDetailRow(
            icon: Icons.layers_outlined,
            label: 'Gaty',
            value: house.floorcount?.toString(),
          ),
          _buildDetailRow(
            icon: Icons.attach_money_outlined,
            label: 'Bahasy',
            value: house.price != null ? '${house.price} TMT' : null,
          ),
          _buildDetailRow(
            icon: Icons.remove_red_eye_outlined,
            label: 'Görülen sany',
            value: house.viewcount?.toString(),
          ),
          _buildDetailRow(
            icon: Icons.phone_outlined,
            label: 'Telefon belgi',
            value: house.phoneNumber,
          ),
          _buildDetailRow(
            icon: Icons.build_outlined,
            label: 'Remont görnüşi',
            value: house.remont?.map((e) => e.name).join(', '),
          ),
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
                    .map((spec) => _buildDetailRow(
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
                    .map((s) => _buildDetailRow(
                          icon: Icons.location_on_outlined,
                          label: s.name ?? '',
                          value: '',
                        ))
                    .toList(),
              ],
            ),
          _buildDetailRow(
            icon: Icons.description_outlined,
            label: 'Bellik',
            value: house.otkaz,
          ),
        ],
      ),
    );
  }
}
