import 'package:flutter/material.dart';
// Model dosyanızın yolunu kendi projenize göre güncelleyin
import 'package:jaytap/modules/house_details/models/property_model.dart';

class SpecificationsSection extends StatelessWidget {
  const SpecificationsSection({
    Key? key,
    required this.specifications,
  }) : super(key: key);

  final List<PropertySpecification> specifications;

  Widget _buildSpecificationRow({
    required String label,
    String? value,
  }) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (specifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
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
          const Text(
            'Aýratynlyklary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 50, 50, 50),
            ),
          ),
          const SizedBox(height: 10),
          ...specifications
              .map((spec) => _buildSpecificationRow(
                    label: spec.spec.name ?? '',
                    value: spec.count.toString(),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
