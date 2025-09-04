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
  final UserProfilController userProfilController =
      Get.find<UserProfilController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => HouseDetailsView(
            houseID: widget.property.id, myHouses: widget.myHouses));
      },
      child: widget.isBig
          ? Opacity(
              opacity: Theme.of(context).brightness == Brightness.dark &&
                      widget.property.vip == true
                  ? 0.6
                  : 1.0,
              child: Container(
                decoration: BoxDecoration(
                    gradient: widget.property.vip == true
                        ? LinearGradient(
                            colors: [
                                ColorConstants.premiumColor.withOpacity(.6),
                                Colors.white
                              ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight)
                        : null,
                    color: widget.property.vip == true
                        ? ColorConstants.premiumColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16)),
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                child: _buildCardContent(context),
              ),
            )
          : Opacity(
              opacity: Theme.of(context).brightness == Brightness.dark &&
                      widget.property.vip == true
                  ? 0.6
                  : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: widget.property.vip == true
                      ? LinearGradient(
                          colors: [
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color.fromARGB(255, 254, 212, 42)
                                    .withOpacity(0.9)
                                : ColorConstants.premiumColor,
                            Colors.white
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: widget.property.vip == true
                      ? (Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromARGB(255, 254, 212, 42)
                              .withOpacity(0.9)
                          : ColorConstants.premiumColor)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildCardContent(context),
              ),
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
    final hasMultipleImages =
        property.imgUrlAnother != null && property.imgUrlAnother!.isNotEmpty;

    return AspectRatio(
      aspectRatio: widget.isBig ? 16 / 12 : 16 / 14.6,
      child: ClipRRect(
        borderRadius: widget.isBig
            ? BorderRadius.zero
            : const BorderRadius.vertical(top: Radius.circular(20.0)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasMultipleImages)
              CarouselSlider.builder(
                itemCount: property.imgUrlAnother!.length,
                itemBuilder: (context, itemIndex, pageViewIndex) {
                  return CustomWidgets.imageWidget(
                      property.imgUrlAnother![itemIndex], false, true);
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
              CustomWidgets.imageWidget(
                  property.img ?? '', false, widget.isBig),
            Positioned(
              top: 8,
              left: 8,
              child: widget.myHouses
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: property.confirm == 'waiting'
                            ? Theme.of(context).colorScheme.surface
                            : property.confirm == 'accepted'
                                ? Theme.of(context).colorScheme.surface
                                : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        property.confirm == 'waiting'
                            ? 'status_waiting'.tr
                            : property.confirm == 'accepted'
                                ? 'status_accepted'.tr
                                : 'status_rejected'.tr,
                        style: TextStyle(
                          fontSize: widget.isBig ? 14 : 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: context.border.lowBorderRadius),
                      child: Text(
                        property.category?.name ?? 'Kategorisiz',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: widget.isBig ? 14 : 12,
                            fontWeight: FontWeight.bold),
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
                  children:
                      List.generate(property.imgUrlAnother!.length, (index) {
                    return Container(
                      width: 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
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
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "${property.price} TMT",
                style: context.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Row(children: [
            Icon(
              (property.category?.subcategory.last.titleTk
                              .toString()
                              .toLowerCase() ??
                          "") ==
                      'jaýlar'
                  ? HugeIcons.strokeRoundedHouse01
                  : HugeIcons.strokeRoundedHouse03,
              color: property.vip == true ? Colors.black : Colors.grey,
              size: widget.isBig ? 20 : 14,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "${property.name ?? 'Emlak Adı Yok'}, ${property.square?.toString() ?? '?'} m2",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.isBig ? 16 : 11,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ]),
          Padding(
            padding: EdgeInsets.only(
                bottom: widget.isBig ? 6 : 5, top: widget.isBig ? 6 : 5),
            child: Row(
              children: [
                Icon(
                  IconlyLight.location,
                  color: property.vip == true ? Colors.black : Colors.grey,
                  size: widget.isBig ? 18 : 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "${property.village?.name ?? ''}, ${property.region?.name ?? ''}",
                    style: TextStyle(
                      fontSize: widget.isBig ? 16 : 11,
                      color: property.vip == true ? Colors.black : Colors.grey,
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
                userProfilController.tarifOptions[
                            int.parse(property.owner!.typeTitle.toString())] ==
                        'type_2'
                    ? HugeIcons.strokeRoundedUserGroup03
                    : HugeIcons.strokeRoundedUser02,
                color: property.vip == true ? Colors.black : Colors.grey,
                size: widget.isBig ? 18 : 14,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  userProfilController
                      .tarifOptions[
                          int.parse(property.owner!.typeTitle.toString())]
                      .tr,
                  style: TextStyle(
                    fontSize: widget.isBig ? 16 : 11,
                    color: property.vip == true ? Colors.black : Colors.grey,
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
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text("call".tr,
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onPrimary)),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
