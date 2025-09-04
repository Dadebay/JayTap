// ignore_for_file: deprecated_member_use

import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/shared/extensions/packages.dart';

class AdditionalFeaturesSection extends StatelessWidget {
  const AdditionalFeaturesSection({Key? key, required this.house})
      : super(key: key);
  final PropertyModel house;

  @override
  Widget build(BuildContext context) {
    if (house.extrainform == null || house.extrainform!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
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
            'section_8'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 3.5,
            ),
            itemCount: house.extrainform!.length,
            itemBuilder: (context, index) {
              final feature = house.extrainform![index];

              return Container(
                margin: EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outline, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.4)
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]),
                child: Row(
                  children: [
                    if (feature.img != null && feature.img!.isNotEmpty)
                      Image.network(feature.img!, width: 28, height: 28,
                          errorBuilder: (context, error, stackTrace) {
                        print('Resim yüklenirken hata oluştu: $error');
                        return Icon(IconlyBold.image2,
                            size: 24,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7));
                      }),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature.name ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
