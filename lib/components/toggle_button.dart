import 'package:flutter/material.dart';
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/core/constants/app_sizes.dart';

class ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const ToggleButton({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primary : AppColors.cardBackground,
          foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
        ),
        child: Text(label),
      ),
    );
  }
}