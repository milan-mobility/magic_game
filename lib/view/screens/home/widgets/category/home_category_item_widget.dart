import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';
import 'package:magic_games/view/screens/home/widgets/home_image_placeholder_widget.dart';

class HomeCategoryItemWidget extends StatelessWidget {
  const HomeCategoryItemWidget({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final HomeCategoryData category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: AppResponsive.value(10, tablet: 14),
          vertical: AppResponsive.value(5, tablet: 9),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.color6B35F5 : AppColors.color1C153F,
          borderRadius: BorderRadius.circular(AppResponsive.space(14)),
          border: Border.all(
            color: isSelected ? AppColors.color9B57FF : AppColors.color2A1B59,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CategoryIcon(iconUrl: category.iconUrl),
            SizedBox(width: AppResponsive.space(10)),
            Flexible(
              child: Text(
                category.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: poppinsW500.copyWith(
                  fontSize: AppResponsive.font(12),
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.iconUrl});

  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppResponsive.space(28),
      height: AppResponsive.space(28),
      alignment: Alignment.center,
      child: iconUrl == null || iconUrl!.trim().isEmpty
          ? HomeImagePlaceholderWidget(
              width: AppResponsive.space(20),
              height: AppResponsive.space(20),
              iconSize: AppResponsive.space(14),
              isCircular: true,
            )
          : CachedNetworkImage(
              imageUrl: iconUrl!,
              width: AppResponsive.space(20),
              height: AppResponsive.space(20),
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => HomeImagePlaceholderWidget(
                width: AppResponsive.space(20),
                height: AppResponsive.space(20),
                iconSize: AppResponsive.space(14),
                isCircular: true,
              ),
            ),
    );
  }
}
