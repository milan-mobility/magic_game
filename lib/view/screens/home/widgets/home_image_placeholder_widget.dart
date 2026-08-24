import 'package:flutter/material.dart';
import 'package:magic_games/helpers/app_colors.dart';

class HomeImagePlaceholderWidget extends StatelessWidget {
  const HomeImagePlaceholderWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.iconSize = 20,
    this.isCircular = false,
  });

  final double? width;
  final double? height;
  final double? borderRadius;
  final double iconSize;
  final bool isCircular;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular
            ? null
            : BorderRadius.circular(borderRadius ?? 12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.color2C175B, AppColors.color170B3B],
        ),
      ),
      child: Icon(
        Icons.image_outlined,
        color: AppColors.colorD5CCF2,
        size: iconSize,
      ),
    );
  }
}
