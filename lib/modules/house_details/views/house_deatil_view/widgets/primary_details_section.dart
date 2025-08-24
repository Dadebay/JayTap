import 'package:hugeicons/hugeicons.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/detail_row.dart';
import 'package:jaytap/shared/extensions/packages.dart';

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
    return DetailRow(
      icon: icon,
      label: label,
      value: value,
      iconColor: Colors.grey,
      iconSize: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'primary_section'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 50, 50, 50),
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                icon: IconlyLight.category,
                label: 'Bölümi',
                value: house.category?.titleTk,
              ),
              _buildDetailRow(
                icon: HugeIcons.strokeRoundedRuler,
                label: 'Umumy meýdany',
                value: house.square != null ? '${house.square} m²' : null,
              ),
              _buildDetailRow(
                icon: HugeIcons.strokeRoundedHome11,
                label: 'Otag sany',
                value: house.roomcount?.toString(),
              ),
              _buildDetailRow(
                icon: HugeIcons.strokeRoundedBuilding02,
                label: 'Gaty',
                value: house.floorcount?.toString(),
              ),
              _buildDetailRow(
                icon: IconlyLight.setting,
                label: 'Remont görnüşi',
                value: house.remont?.map((e) => e.name).join(', '),
              ),
              _buildDetailRow(
                icon: IconlyLight.document,
                label: 'Bellik',
                value: house.otkaz,
              ),
            ],
          )),
    );
  }
}
