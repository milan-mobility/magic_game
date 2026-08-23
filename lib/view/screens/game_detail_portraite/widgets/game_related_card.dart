import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/extensions/string_ext.dart';
import 'package:magic_games/helpers/styles.dart';

class GameRelatedCard extends StatelessWidget {
  const GameRelatedCard({
    super.key,
    required this.game,
    required this.onTap,
    required this.onDownload,
  });

  final Games game;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = (game.icon?.isNotEmpty ?? false)
        ? game.icon!.imageUrl()
        : (game.banner?.isNotEmpty ?? false)
              ? game.banner!.imageUrl()
              : '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppResponsive.space(18)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.color170B3B.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(AppResponsive.space(18)),
          border: Border.all(
            color: AppColors.color7433F9.withValues(alpha: 0.4),
          ),
        ),
        padding: EdgeInsets.all(AppResponsive.space(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppResponsive.space(14)),
              child: AspectRatio(
                aspectRatio: 1,
                child: imageUrl.isEmpty
                    ? Container(
                        color: AppColors.color2A1B59,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.sports_esports_rounded,
                          color: AppColors.white.withValues(alpha: 0.9),
                          size: AppResponsive.value(34, tablet: 42),
                        ),
                      )
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                              final BuildContext context,
                              final Object error,
                              final StackTrace? stackTrace,
                            ) => Container(
                              color: AppColors.color2A1B59,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.sports_esports_rounded,
                                color: AppColors.white.withValues(alpha: 0.9),
                                size: AppResponsive.value(34, tablet: 42),
                              ),
                            ),
                      ),
              ),
            ),
            Gap(AppResponsive.space(10)),
            Text(
              game.name?.trim().isNotEmpty == true ? game.name!.trim() : 'Game'.tr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: poppinsW600.copyWith(
                fontSize: AppResponsive.font(15),
                color: AppColors.white,
                height: 1.25,
              ),
            ),
            Gap(AppResponsive.space(8)),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppResponsive.space(10),
                      vertical: AppResponsive.space(6),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.color5820CB.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(AppResponsive.space(12)),
                    ),
                    child: Text(
                      _primaryTag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: poppinsW500.copyWith(
                        fontSize: AppResponsive.font(12),
                        color: AppColors.colorD5CCF2,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppResponsive.space(8)),
                InkWell(
                  onTap: onDownload,
                  borderRadius: BorderRadius.circular(AppResponsive.space(12)),
                  child: Container(
                    width: AppResponsive.space(38),
                    height: AppResponsive.space(38),
                    decoration: BoxDecoration(
                      color: AppColors.color1A0B53,
                      borderRadius: BorderRadius.circular(AppResponsive.space(12)),
                      border: Border.all(
                        color: AppColors.color7433F9.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      Icons.download_rounded,
                      color: AppColors.color8752FF,
                      size: AppResponsive.space(22),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _primaryTag {
    final String categoryName = game.categoryName?.trim() ?? '';
    if (categoryName.isNotEmpty) {
      return categoryName.split(',').first.trim();
    }

    final String keyword = game.keyword?.trim() ?? '';
    if (keyword.isNotEmpty) {
      return keyword.split(',').first.trim();
    }

    return 'Featured'.tr;
  }
}
