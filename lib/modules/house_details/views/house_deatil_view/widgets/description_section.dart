import 'package:flutter/material.dart';
// Model dosyanızın yolunu kendi projenize göre güncelleyin
import 'package:jaytap/modules/house_details/models/property_model.dart';

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
        color: Colors.white,
        // Kenarları 15 birim yuvarlatır
        borderRadius: BorderRadius.circular(15),
        // Gölgelendirme efekti ekler
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
            'Hakynda',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 50, 50, 50),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            house.description!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color.fromARGB(255, 84, 76, 76),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
