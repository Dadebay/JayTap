import 'package:flutter/material.dart';

class DetailRow extends StatelessWidget {
  const DetailRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconSize,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
