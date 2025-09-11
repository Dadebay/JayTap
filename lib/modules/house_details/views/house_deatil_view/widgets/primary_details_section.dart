import 'package:hugeicons/hugeicons.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/detail_row.dart';
import 'package:jaytap/shared/extensions/packages.dart';

class PrimaryDetailsSection extends StatelessWidget {
  const PrimaryDetailsSection({Key? key, required this.house})
      : super(key: key);
  final PropertyModel house;

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    String? value,
  }) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return DetailRow(
      icon: icon,
      label: label.tr,
      value: value,
      iconColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(
                        0.4) // Use onSurface for shadow in dark mode
                    : Colors.grey.withOpacity(0.2),
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              _buildDetailRow(
                context: context,
                icon: IconlyLight.category,
                label: 'section_1',
                value: house.category?.name,
              ),
              _buildDetailRow(
                context: context,
                icon: HugeIcons.strokeRoundedRuler,
                label: 'section_2',
                value: house.square != null ? '${house.square} m²' : null,
              ),
              _buildDetailRow(
                context: context,
                icon: HugeIcons.strokeRoundedHome11,
                label: 'section_3',
                value: house.roomcount?.toString(),
              ),
              _buildDetailRow(
                context: context,
                icon: HugeIcons.strokeRoundedBuilding02,
                label: 'section_4',
                value: house.floorcount?.toString(),
              ),
              _buildDetailRow(
                context: context,
                icon: IconlyLight.setting,
                label: 'section_5',
                value: house.remont?.map((e) => e.name).join(', '),
              ),
              _buildDetailRow(
                context: context,
                icon: IconlyLight.document,
                label: 'section_6',
                value: house.otkaz,
              ),
            ],
          )),
    );
  }
}
