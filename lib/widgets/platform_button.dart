import 'package:flutter/material.dart';

class PlatformButton extends StatelessWidget {
  final String title;
  final Color primaryColor;
  final Color textColor;
  final bool isSelected;
  final VoidCallback onPressed;
  final IconData? icon;

  const PlatformButton({
    Key? key,
    required this.title,
    required this.primaryColor,
    required this.textColor,
    required this.isSelected,
    required this.onPressed,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? primaryColor : Colors.white,
          foregroundColor: isSelected ? textColor : primaryColor,
          elevation: isSelected ? 4 : 2,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: primaryColor,
              width: isSelected ? 0 : 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}