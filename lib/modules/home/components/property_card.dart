import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:jaytap/modules/favorites/views/fav_button.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/house_details_view.dart';
import 'package:jaytap/shared/extensions/extensions.dart';
import 'package:kartal/kartal.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final bool isBig;
  const PropertyCard({
    super.key,
    required this.property,
    required this.isBig,
  });

  @override
  Widget build(BuildContext context) {
    final tag = property.category?.titleTk ?? 'Kategorisiz';
    final price = property.price?.toString() ?? 'Bilinmiyor';
    final details = "${property.name ?? ''}, ${property.square?.toString() ?? '?'} m²";
    final location = "${property.village?.name ?? ''}, ${property.region?.name ?? ''}";
    final isPremium = property.vip ?? false;
    final imageUrl = property.img ?? '';
    return GestureDetector(
      onTap: () {
        Get.to(() => HouseDetailsView(houseID: property.id));
      },
      child: Container(
        decoration: BoxDecoration(
            color: context.whiteColor,
            borderRadius: isBig ? BorderRadius.circular(10) : context.border.lowBorderRadius,
            gradient: isPremium
                ? LinearGradient(colors: [Colors.amber.withOpacity(.7), Colors.white], begin: Alignment.centerLeft, end: Alignment.centerRight, stops: const [0.0, 1.0], tileMode: TileMode.clamp)
                : null,
            boxShadow: [
              BoxShadow(color: context.greyColor.withOpacity(.2), spreadRadius: 3, blurRadius: 3),
            ]),
        child: ClipRRect(
          borderRadius: isBig ? BorderRadius.circular(10) : context.border.lowBorderRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: Get.size.width,
                      imageBuilder: (context, imageProvider) => Container(
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) {
                        return Icon(IconlyLight.infoSquare);
                      },
                    ),
                    Positioned(
                      top: 0,
                      left: -2,
                      // right: 20,
                      child: Container(
                        width: 90,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.whiteColor.withOpacity(.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(tag,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: tag == "Arenda" ? Colors.green : Colors.blue, fontSize: isBig ? 20 : 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Positioned(top: 10, right: 5, child: FavButton(itemId: property.id)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(isBig ? 14 : 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("$price TMT", style: TextStyle(fontSize: isBig ? 24 : 20, fontWeight: FontWeight.bold, color: Colors.green)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 4),
                      child: Text(details, style: TextStyle(fontSize: isBig ? 20 : 16, color: Colors.black, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: isBig ? 8 : 4),
                          child: Icon(IconlyBold.location, color: Colors.green, size: isBig ? 24 : 17),
                        ),
                        Expanded(
                          child: Text(location, style: TextStyle(fontSize: isBig ? 20 : 16, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
