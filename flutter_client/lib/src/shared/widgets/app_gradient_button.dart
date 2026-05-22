import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_gradients.dart';

class AppGradientButton extends StatelessWidget {
  const AppGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.height = 48.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final button = DecoratedBox(
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : AppGradients.brand,
        color: onPressed == null ? AppColors.border : null,
        borderRadius: BorderRadius.circular(fullWidth ? 14 : 12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(fullWidth ? 14 : 12),
          child: Center(
            widthFactor: fullWidth ? null : 1,
            heightFactor: fullWidth ? null : 1,
            child: Padding(
              padding: fullWidth
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            color: AppColors.white,
                            size: fullWidth ? 20 : 18,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: fullWidth ? 15 : 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, height: height, child: button);
  }
}
