import 'package:hugeicons/hugeicons.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/house_details_view.dart';
import 'package:jaytap/shared/extensions/packages.dart';
import 'package:kartal/kartal.dart';

// 1. ADIM: Widget'ı StatefulWidget'a dönüştürdük.
class PropertyCard extends StatefulWidget {
  final PropertyModel property;
  final bool isBig;
  final bool myHouses;

  const PropertyCard({
    super.key,
    required this.property,
    required this.isBig,
    required this.myHouses,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  // 2. ADIM: Aktif resmin indeksini tutacak state değişkeni.
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Değişkenlere erişim için 'widget.' ön ekini kullanıyoruz.
    final property = widget.property;
    final isBig = widget.isBig;
    final myHouses = widget.myHouses;
    final tag = property.category?.titleTk ?? 'Kategorisiz';
    final price = property.price?.toString() ?? 'Bilinmiyor';
    final title = property.name ?? 'Emlak Adı Yok';
    final details = "${property.square?.toString() ?? '?'} m²";
    final location =
        "${property.village?.name ?? ''}, ${property.region?.name ?? ''}";
    final imageUrl = property.img ?? '';
    final hasMultipleImages =
        property.imgUrlAnother != null && property.imgUrlAnother!.isNotEmpty;
    final double cardBorderRadius = isBig ? 12.0 : 20.0;
    final double titleFontSize = isBig ? 18 : 15;
    final double priceFontSize = isBig ? 22 : 18;
    final double locationFontSize = isBig ? 14 : 12;
    final double locationIconSize = isBig ? 18 : 15;

    return GestureDetector(
      onTap: () {
        Get.to(
            () => HouseDetailsView(houseID: property.id, myHouses: myHouses));
      },
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(
              context,
              cardBorderRadius,
              hasMultipleImages,
              imageUrl,
              tag,
            ),
            _buildInfoSection(
              context,
              price,
              title,
              details,
              location,
              priceFontSize,
              titleFontSize,
              locationFontSize,
              locationIconSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    double borderRadius,
    bool hasMultipleImages,
    String imageUrl,
    String tag,
  ) {
    return AspectRatio(
      aspectRatio: 16 / 14,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasMultipleImages)
              CarouselSlider.builder(
                itemCount: widget.property.imgUrlAnother!.length,
                itemBuilder: (context, itemIndex, pageViewIndex) {
                  return CustomWidgets.imageWidget(
                      widget.property.imgUrlAnother![itemIndex], false);
                },
                options: CarouselOptions(
                  height: double.infinity,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
              )
            else
              CustomWidgets.imageWidget(imageUrl, false),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: context.border.lowBorderRadius,
                ),
                child: Text(
                  tag,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: tag.toLowerCase().toString() == "arenda"
                        ? ColorConstants.greenColor
                        : ColorConstants.kPrimaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: FavButton(itemId: widget.property.id),
            ),
            if (hasMultipleImages)
              Positioned(
                bottom: 4.0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.property.imgUrlAnother!.map((url) {
                    int index = widget.property.imgUrlAnother!.indexOf(url);
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.white // Aktif renk
                            : Colors.white.withOpacity(0.4), // Pasif renk
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String price,
    String title,
    String details,
    String location,
    double priceFontSize,
    double titleFontSize,
    double locationFontSize,
    double locationIconSize,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$price TMT",
            style: TextStyle(
              fontSize: priceFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              Icon(
                HugeIcons.strokeRoundedHouse03,
                color: Colors.grey.shade600,
                size: locationIconSize,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "$title, $details",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 3, top: 3),
            child: Row(
              children: [
                Icon(
                  IconlyLight.location,
                  color: Colors.grey.shade600,
                  size: locationIconSize,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(
                      fontSize: locationFontSize,
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                IconlyLight.profile,
                color: Colors.grey.shade600,
                size: locationIconSize,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Eyesi",
                  style: TextStyle(
                    fontSize: locationFontSize,
                    color: Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
