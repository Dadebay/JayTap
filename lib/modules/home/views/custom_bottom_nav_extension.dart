import 'package:flutter/material.dart';
import 'package:jaytap/core/theme/custom_color_scheme.dart';
import 'package:jaytap/shared/sizes/image_sizes.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<IconData> unselectedIcons;
  final List<IconData> selectedIcons;
  final Function(int) onTap;

  CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.unselectedIcons,
    required this.selectedIcons,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color selectedIconColor = isDarkMode ? colorScheme.onSurface : ColorConstants.kPrimaryColor2;
    final Color unselectedIconColor = colorScheme.onSurface.withOpacity(0.6);

    return Container(
      height: WidgetSizes.size64.value - 8,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(.2),
            spreadRadius: 1,
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(selectedIcons.length, (index) {
          final isSelected = index == currentIndex;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: isSelected ? 0.0 : 1.0, end: isSelected ? 1.0 : 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  color: Colors.transparent,
                  width: 70,
                  height: 50,
                  child: Icon(
                    isSelected ? selectedIcons[index] : unselectedIcons[index],
                    size: 23,
                    color: Color.lerp(
                      unselectedIconColor, // Başlangıç rengi (seçili değil)
                      selectedIconColor, // Bitiş rengi (seçili)
                      value,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
