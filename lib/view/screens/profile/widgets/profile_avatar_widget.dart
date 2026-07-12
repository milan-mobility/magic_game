import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';

class ProfileAvatarWidget extends StatelessWidget {
  const ProfileAvatarWidget({super.key, this.size, this.onEditTap});

  final double? size;
  final VoidCallback? onEditTap;

  @override
  Widget build(BuildContext context) {
    final double avatarSize = size ?? AppResponsive.value(85, tablet: 105);

    return SizedBox(
      width: avatarSize + AppResponsive.space(18),
      height: avatarSize + AppResponsive.space(18),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.color8752FF.withValues(alpha: 0.8),
                width: 1.4,
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.color5820CB, AppColors.color4B21CA],
              ),
            ),
          ),
          Positioned(
            right: 15,
            bottom: 15,
            child: InkWell(
              onTap: onEditTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: AppResponsive.space(32),
                height: AppResponsive.space(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.color5820CB,
                  border: Border.all(color: AppColors.color9B57FF, width: 1.2),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  Assets.svg.icEdit,
                  width: AppResponsive.space(18),
                  height: AppResponsive.space(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
