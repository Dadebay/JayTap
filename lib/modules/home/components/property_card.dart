import 'package:hugeicons/hugeicons.dart';

import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/house_details/models/property_model.dart';
import 'package:jaytap/modules/house_details/views/house_deatil_view/house_details_view.dart';
import 'package:jaytap/modules/user_profile/controllers/user_profile_controller.dart';
import 'package:jaytap/shared/extensions/packages.dart';
import 'package:kartal/kartal.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyCard extends StatefulWidget {
  final PropertyModel property;
  final bool isBig;
  final bool myHouses;

  const PropertyCard({
    super.key,
    required this.property,
    this.isBig = false,
    required this.myHouses,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  int _currentImageIndex = 0;
  final UserProfilController userProfilController = Get.find<UserProfilController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => HouseDetailsView(houseID: widget.property.id, myHouses: widget.myHouses));
      },
      child: widget.isBig
          ? Container(
              decoration: BoxDecoration(
                  gradient:
                      widget.property.vip == true ? LinearGradient(colors: [ColorConstants.premiumColor.withOpacity(.6), Colors.white], begin: Alignment.centerLeft, end: Alignment.centerRight) : null,
                  color: widget.property.vip == true ? ColorConstants.premiumColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
              child: _buildCardContent(context),
            )
          : Container(
              decoration: BoxDecoration(
                  gradient: widget.property.vip == true ? LinearGradient(colors: [ColorConstants.premiumColor, Colors.white], begin: Alignment.centerLeft, end: Alignment.centerRight) : null,
                  color: widget.property.vip == true ? ColorConstants.premiumColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(16)),
              child: _buildCardContent(context),
            ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(context),
        _buildInfoSection(context),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final property = widget.property;
    final hasMultipleImages = property.imgUrlAnother != null && property.imgUrlAnother!.isNotEmpty;

    return AspectRatio(
      aspectRatio: widget.isBig ? 16 / 13 : 16 / 15,
      child: ClipRRect(
        borderRadius: widget.isBig ? BorderRadius.zero : const BorderRadius.vertical(top: Radius.circular(20.0)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasMultipleImages)
              CarouselSlider.builder(
                itemCount: property.imgUrlAnother!.length,
                itemBuilder: (context, itemIndex, pageViewIndex) {
                  return CustomWidgets.imageWidget(property.imgUrlAnother![itemIndex], false, true);
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
              CustomWidgets.imageWidget(property.img ?? '', false, widget.isBig),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white, borderRadius: context.border.lowBorderRadius),
                child: Text(
                  property.category?.titleTk ?? 'Kategorisiz',
                  style: TextStyle(color: Colors.black, fontSize: widget.isBig ? 16 : 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: FavButton(itemId: property.id),
            ),
            if (hasMultipleImages)
              Positioned(
                bottom: 4.0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(property.imgUrlAnother!.length, (index) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index ? Colors.white : Colors.white.withOpacity(0.4),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Widget _buildInfoSection(BuildContext context) {
    final property = widget.property;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                property.price.toString(),
                style: TextStyle(
                  fontSize: widget.isBig ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                ' TMT',
                style: TextStyle(
                  fontSize: widget.isBig ? 18 : 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Row(children: [
            Icon(
              (property.category?.subcategory.last.titleTk.toString().toLowerCase() ?? "") == 'jaýlar' ? HugeIcons.strokeRoundedHouse01 : HugeIcons.strokeRoundedHouse03,
              color: property.vip == true ? Colors.black : Colors.grey.shade600,
              size: widget.isBig ? 20 : 15,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "${property.name ?? 'Emlak Adı Yok'}, ${property.square?.toString() ?? '?'} m2",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.isBig ? 18 : 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ]),
          Padding(
            padding: EdgeInsets.only(bottom: widget.isBig ? 6 : 3, top: widget.isBig ? 6 : 3),
            child: Row(
              children: [
                Icon(
                  IconlyLight.location,
                  color: property.vip == true ? Colors.black : Colors.grey.shade600,
                  size: widget.isBig ? 20 : 15,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${property.village?.name ?? ''}, ${property.region?.name ?? ''}",
                    style: TextStyle(
                      fontSize: widget.isBig ? 16 : 12,
                      color: property.vip == true ? Colors.black : Colors.grey.shade700,
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
                userProfilController.tarifOptions[int.parse(property.owner!.typeTitle.toString())] == 'type_2' ? HugeIcons.strokeRoundedUserGroup03 : HugeIcons.strokeRoundedUser02,
                color: property.vip == true ? Colors.black : Colors.grey.shade600,
                size: widget.isBig ? 20 : 15,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  userProfilController.tarifOptions[int.parse(property.owner!.typeTitle.toString())].tr,
                  style: TextStyle(
                    fontSize: widget.isBig ? 16 : 12,
                    color: property.vip == true ? Colors.black : Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          widget.isBig
              ? Container(
                  width: Get.size.width,
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      _makePhoneCall(widget.property.phoneNumber!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff009EFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text("Позвонить", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18, color: Colors.white)),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
