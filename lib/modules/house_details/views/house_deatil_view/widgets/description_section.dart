import 'package:flutter/material.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';

class DescriptionSection extends StatelessWidget {
  const DescriptionSection({Key? key, required this.house}) : super(key: key);
  final PropertyModel house;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hakynda',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 84, 76, 76))),
          const SizedBox(height: 8),
          Text(
            house.description ?? '',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 84, 76, 76)),
          ),
        ],
      ),
    );
  }
}