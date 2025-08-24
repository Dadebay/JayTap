import 'package:flutter/material.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';

class NearbyPlacesSection extends StatelessWidget {
  const NearbyPlacesSection({
    Key? key,
    required this.nearbyPlaces,
  }) : super(key: key);

  final List<Sphere> nearbyPlaces;

  @override
  Widget build(BuildContext context) {
    if (nearbyPlaces.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
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
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Text(
              'Gurşaw / Merkezler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 50, 50, 50),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: nearbyPlaces.length,
              itemBuilder: (context, index) {
                final place = nearbyPlaces[index];

                return Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9F5FE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFB3D9F8),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      place.name ?? '',
                      style: const TextStyle(
                        color: Color(0xFF0D6AB7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
