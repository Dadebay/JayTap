import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                icon: IconlyLight.category, // Bölümi
                label: 'Bölümi',
                value: house.category?.titleTk,
              ),
              _buildDetailRow(
                icon: IconlyLight.paper, // Umumy meýdany
                label: 'Umumy meýdany',
                value: house.square != null ? '${house.square} m²' : null,
              ),
              _buildDetailRow(
                icon: IconlyLight.home, // Otag sany
                label: 'Otag sany',
                value: house.roomcount?.toString(),
              ),
              _buildDetailRow(
                icon: IconlyLight.activity,
                label: 'Gaty',
                value: house.floorcount?.toString(),
              ),
              _buildDetailRow(
                icon: IconlyLight.setting,
                label: 'Remont görnüşi',
                value: house.remont?.map((e) => e.name).join(', '),
              ),
              if (house.specifications != null &&
                  house.specifications!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Aýratynlyklary',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ...house.specifications!
                        .map((spec) => _buildDetailRow(
                              icon: IconlyLight.tickSquare,
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
                    const Text(
                      'Ýakyn ýerleri',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ...house.sphere!
                        .map((s) => _buildDetailRow(
                              icon: IconlyLight
                                  .location, // location_on_outlined yerine
                              label: s.name ?? '',
                              value: '',
                            ))
                        .toList(),
                  ],
                ),
              _buildDetailRow(
                icon: IconlyLight.document, // description_outlined yerine
                label: 'Bellik',
                value: house.otkaz,
              ),
            ],
          )),
    );
  }
}
