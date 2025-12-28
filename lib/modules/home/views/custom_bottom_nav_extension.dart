import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/modules/chat/controllers/chat_controller.dart';
import 'package:jaytap/shared/sizes/image_sizes.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<IconData> unselectedIcons;
  final List<IconData> selectedIcons;
  final Function(int) onTap;
  final List<String> pageNames;

  CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.unselectedIcons,
    required this.selectedIcons,
    required this.pageNames,
    Key? key,
  }) : super(key: key);

  final ChatController chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color selectedIconColor = isDarkMode ? colorScheme.onSurface : ColorConstants.kPrimaryColor;
    final Color unselectedIconColor = Colors.black;

    return Container(
      height: WidgetSizes.size64.value,
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(selectedIcons.length, (index) {
          final isSelected = index == currentIndex;

          Widget navIcon;

          if (index == 2) {
            // For the chat icon, build the complete reactive widget tree at once.
            navIcon = Obx(() {
              return Badge(
                isLabelVisible: chatController.totalUnreadCount.value > 0,
                label: Text(chatController.totalUnreadCount.value.toString()),
                child: Icon(
                  isSelected ? selectedIcons[index] : unselectedIcons[index],
                  size: 23,
                  color: isSelected ? selectedIconColor : unselectedIconColor,
                ),
              );
            });
          } else {
            // For all other icons, just build the simple Icon.
            navIcon = Icon(
              isSelected ? selectedIcons[index] : unselectedIcons[index],
              size: 23,
              color: isSelected ? selectedIconColor : unselectedIconColor,
            );
          }

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                color: Colors.transparent, // Ensures the whole area is tappable
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    navIcon,
                    const SizedBox(height: 4),
                    Text(
                      pageNames[index].tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? selectedIconColor : unselectedIconColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
