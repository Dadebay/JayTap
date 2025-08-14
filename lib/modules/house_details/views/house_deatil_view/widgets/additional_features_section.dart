import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/widgets/feature_chip.dart';

class AdditionalFeaturesSection extends StatelessWidget {
  const AdditionalFeaturesSection({Key? key, required this.house}) : super(key: key);
  final PropertyModel house;

  IconData _getIconForFeature(String featureName) {
    final name = featureName.toLowerCase();
    switch (name) {
      case 'wifi':
        return HugeIcons.strokeRoundedWifi01;
      case 'kir maşyn':
        return IconlyLight.setting;
      case 'aşhana':
      case 'kuhniý garnatur':
        return IconlyLight.category;
      case 'holadilnik':
        return IconlyLight.buy;
      case 'telewizor':
        return HugeIcons.strokeRoundedTv01;
      case 'Kondisener':
        return IconlyLight.folder;
      case 'şkaf':
        return IconlyLight.folder;
      case 'spalny':
        return IconlyLight.folder;
      case 'basseýn':
        return IconlyLight.location;
      case 'lift':
        return IconlyLight.swap;
      case 'ýyladyjy':
      case 'ýyladyş ulgamy':
        return IconlyLight.folder;
      case 'balkon':
        return IconlyLight.home;
      case 'vanna':
        return IconlyLight.shieldDone;
      case 'stol':
        return IconlyLight.work;
      default:
        return IconlyLight.tickSquare;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Goşmaça maglumat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: house.extrainform!
                .map((e) => FeatureChip(
                      icon: _getIconForFeature(e.name ?? ''),
                      label: e.name ?? '',
                      imageUrl: e.img,
                    ))
                .toList(),
          )
        ],
      ),
    );
  }
}
