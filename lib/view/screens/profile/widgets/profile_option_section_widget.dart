import 'package:flutter/material.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/profile/controller/profile_controller.dart';
import 'package:magic_games/view/screens/profile/widgets/profile_option_tile_widget.dart';

class ProfileOptionSectionWidget extends StatelessWidget {
  const ProfileOptionSectionWidget({super.key, required this.section});

  final ProfileOptionSectionData section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: poppinsW600.copyWith(
            fontSize: AppResponsive.font(18),
            color: AppColors.white,
          ),
        ),
        SizedBox(height: AppResponsive.space(12)),
        Container(
          decoration: BoxDecoration(
            color: AppColors.color170B3B,
            borderRadius: BorderRadius.circular(AppResponsive.space(16)),
            border: Border.all(color: AppColors.color2A1B59),
          ),
          child: Column(
            children: List<Widget>.generate(section.items.length * 2 - 1, (
              final int index,
            ) {
              if (index.isOdd) {
                return Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: AppResponsive.space(14),
                  ),
                  height: 1,
                  color: AppColors.color2A1B59,
                );
              }

              final ProfileOptionItemData item = section.items[index ~/ 2];
              return ProfileOptionTileWidget(item: item);
            }),
          ),
        ),
      ],
    );
  }
}
