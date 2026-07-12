import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/profile/controller/profile_controller.dart';

class ProfileOptionTileWidget extends StatelessWidget {
  const ProfileOptionTileWidget({super.key, required this.item});

  final ProfileOptionItemData item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(AppResponsive.space(16)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppResponsive.space(14),
            vertical: AppResponsive.space(16),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                item.iconAsset,
                width: AppResponsive.space(20),
                height: AppResponsive.space(20),
              ),
              SizedBox(width: AppResponsive.space(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: poppinsW600.copyWith(
                        fontSize: AppResponsive.font(14),
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: AppResponsive.space(3)),
                    Text(
                      item.subtitle,
                      style: poppinsW400.copyWith(
                        fontSize: AppResponsive.font(12),
                        color: AppColors.colorD5CCF2,
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasText(item.valueText)) ...[
                _OptionValue(item: item),
                SizedBox(width: AppResponsive.space(10)),
              ],
              SvgPicture.asset(
                'assets/svg/ic_next.svg',
                width: AppResponsive.space(9),
                height: AppResponsive.space(14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasText(final String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}

class _OptionValue extends StatelessWidget {
  const _OptionValue({required this.item});

  final ProfileOptionItemData item;

  @override
  Widget build(BuildContext context) {
    switch (item.valueStyle) {
      case ProfileOptionValueStyle.badge:
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppResponsive.space(16),
            vertical: AppResponsive.space(8),
          ),
          decoration: BoxDecoration(
            color: AppColors.color2C175B,
            borderRadius: BorderRadius.circular(AppResponsive.space(12)),
          ),
          child: Text(
            item.valueText!,
            style: poppinsW500.copyWith(
              fontSize: AppResponsive.font(12),
              color: AppColors.colorD5CCF2,
            ),
          ),
        );
      case ProfileOptionValueStyle.text:
        return Text(
          item.valueText!,
          style: poppinsW500.copyWith(
            fontSize: AppResponsive.font(14),
            color: AppColors.color9794B0,
          ),
        );
    }
  }
}
