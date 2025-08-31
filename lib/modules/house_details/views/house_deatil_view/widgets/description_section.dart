import 'package:flutter/material.dart';
// Model dosyanızın yolunu kendi projenize göre güncelleyin
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/shared/extensions/packages.dart';

class DescriptionSection extends StatelessWidget {
  const DescriptionSection({Key? key, required this.house}) : super(key: key);
  final PropertyModel house;

  @override
  Widget build(BuildContext context) {
    // Eğer açıklama metni boş veya null ise, hiçbir şey gösterme
    if (house.description == null || house.description!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // Açıklama doluysa, tasarıma uygun kartı oluştur
    return Container(
      // Genişliği tam ekran yapar
      width: double.infinity,
      // Sağdan ve soldan 10 birim boşluk bırakır
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      // İçerik için iç boşluklar
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        // Kenarları 15 birim yuvarlatır
        borderRadius: BorderRadius.circular(15),
        // Gölgelendirme efekti ekler
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.4)
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
            'section_10'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            house.description!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
