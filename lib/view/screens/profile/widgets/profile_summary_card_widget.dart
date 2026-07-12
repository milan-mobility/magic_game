import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/profile/controller/profile_controller.dart';
import 'package:magic_games/view/screens/profile/widgets/profile_action_button.dart';
import 'package:magic_games/view/screens/profile/widgets/profile_avatar_widget.dart';
import 'package:magic_games/view/screens/profile/widgets/profile_stat_item_widget.dart';

class ProfileSummaryCardWidget extends StatelessWidget {
  const ProfileSummaryCardWidget({
    super.key,
    required this.playerName,
    required this.playerType,
    required this.description,
    required this.stats,
    this.onEditTap,
    this.onLogoutTap,
  });

  final String playerName;
  final String playerType;
  final String description;
  final List<ProfileStatData> stats;
  final VoidCallback? onEditTap;
  final VoidCallback? onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.color170B3B,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.color2A1B59, width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppResponsive.space(20)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileAvatarWidget(onEditTap: onEditTap),
                Gap(AppResponsive.space(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppResponsive.space(10),
                        runSpacing: AppResponsive.space(8),
                        children: [
                          Text(
                            playerName,
                            style: poppinsW600.copyWith(
                              fontSize: AppResponsive.font(20),
                              color: AppColors.white,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppResponsive.space(10),
                              vertical: AppResponsive.space(4),
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.color2C175B,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              playerType,
                              style: poppinsW500.copyWith(
                                fontSize: AppResponsive.font(12),
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap(AppResponsive.space(10)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            Assets.svg.icShieldProfile,
                            width: AppResponsive.space(18),
                            height: AppResponsive.space(18),
                          ),
                          Gap(AppResponsive.space(8)),
                          Expanded(
                            child: Text(
                              description,
                              style: poppinsW400.copyWith(
                                fontSize: AppResponsive.font(12),
                                height: 1.45,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap(AppResponsive.space(14)),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: AppResponsive.value(220, tablet: 260),
                          maxHeight: AppResponsive.value(40, tablet: 55),
                        ),
                        child: ProfileActionButton(
                          label: 'Log out',
                          iconAsset: Assets.svg.icLogout,
                          onTap: onLogoutTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppResponsive.space(18),
              vertical: AppResponsive.space(18),
            ),
            decoration: BoxDecoration(
              color: AppColors.color211557,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(AppResponsive.space(18)),
                bottomRight: Radius.circular(AppResponsive.space(18)),
              ),
            ),
            child: Row(
              children: List<Widget>.generate(stats.length * 2 - 1, (
                final int index,
              ) {
                if (index.isOdd) {
                  return Container(
                    width: 1,
                    height: AppResponsive.space(68),
                    color: AppColors.color2A1B59,
                  );
                }

                final ProfileStatData stat = stats[index ~/ 2];
                return Expanded(
                  child: ProfileStatItemWidget(
                    iconAsset: stat.iconAsset,
                    value: stat.value,
                    label: stat.label,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
