import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/extensions/string_ext.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/home/widgets/home_image_placeholder_widget.dart';

class SearchGameListItemWidget extends StatelessWidget {
  const SearchGameListItemWidget({
    super.key,
    required this.game,
    required this.showInstallAction,
    required this.showPlayAction,
    required this.showSubscribeAction,
    required this.onTap,
    required this.onInstallTap,
    required this.onPlayTap,
    required this.onSubscribeTap,
  });

  final Games game;
  final bool showInstallAction;
  final bool showPlayAction;
  final bool showSubscribeAction;
  final VoidCallback onTap;
  final VoidCallback onInstallTap;
  final VoidCallback onPlayTap;
  final VoidCallback onSubscribeTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppResponsive.space(12),
          vertical: AppResponsive.space(12),
        ),
        decoration: BoxDecoration(
          color: AppColors.color170B3B,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.color2A1B59, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _SearchGameThumb(iconUrl: game.icon),
            Gap(AppResponsive.space(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.shortname ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: poppinsW600.copyWith(
                      fontSize: AppResponsive.font(16),
                      color: AppColors.white,
                    ),
                  ),
                  if (_hasText(_subtitleText))
                    Text(
                      _subtitleText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: poppinsW400.copyWith(
                        fontSize: AppResponsive.font(13),
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  Gap(AppResponsive.space(8)),
                  Wrap(
                    spacing: AppResponsive.space(6),
                    runSpacing: AppResponsive.space(6),
                    children: _tags
                        .map((final String tag) => _GameTag(label: tag))
                        .toList(),
                  ),
                ],
              ),
            ),
            Gap(AppResponsive.space(12)),
            _SearchGameActions(
              showInstallAction: showInstallAction,
              showPlayAction: showPlayAction,
              showSubscribeAction: showSubscribeAction,
              onInstallTap: onInstallTap,
              onPlayTap: onPlayTap,
              onSubscribeTap: onSubscribeTap,
            ),
          ],
        ),
      ),
    );
  }

  String? get _subtitleText {
    if (_hasText(game.shortdesc)) {
      return game.shortdesc!.trim();
    }

    return null;
  }

  List<String> get _tags {
    final List<String> values = <String>[];

    if (_hasText(game.categoryName)) {
      values.add(game.categoryName!.trim());
    }

    if (_hasText(game.badge)) {
      values.add(game.badge!.trim());
    }

    return values;
  }

  bool _hasText(final String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}

class _SearchGameThumb extends StatelessWidget {
  const _SearchGameThumb({required this.iconUrl});

  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final double size = AppResponsive.value(78, tablet: 92);
    final String? imageUrl = iconUrl != null && iconUrl!.trim().isNotEmpty
        ? iconUrl!.imageUrl()
        : null;

    if (imageUrl == null) {
      return HomeImagePlaceholderWidget(
        width: size,
        height: size,
        borderRadius: 16,
        iconSize: AppResponsive.space(24),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder:
          (final BuildContext context, final ImageProvider<Object> image) =>
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(image: image, fit: BoxFit.cover),
                ),
              ),
      errorWidget: (_, _, _) => HomeImagePlaceholderWidget(
        width: size,
        height: size,
        borderRadius: 16,
        iconSize: AppResponsive.space(24),
      ),
    );
  }
}

class _SearchGameActionButton extends StatelessWidget {
  const _SearchGameActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: AppResponsive.space(42),
        height: AppResponsive.space(42),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.color5820CB, width: 1),
          color: AppColors.color170B3B,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: AppColors.white,
          size: AppResponsive.space(24),
        ),
      ),
    );
  }
}

class _SearchGameActions extends StatelessWidget {
  const _SearchGameActions({
    required this.showInstallAction,
    required this.showPlayAction,
    required this.showSubscribeAction,
    required this.onInstallTap,
    required this.onPlayTap,
    required this.onSubscribeTap,
  });

  final bool showInstallAction;
  final bool showPlayAction;
  final bool showSubscribeAction;
  final VoidCallback onInstallTap;
  final VoidCallback onPlayTap;
  final VoidCallback onSubscribeTap;

  @override
  Widget build(BuildContext context) {
    final bool hasPrimaryActions = showInstallAction || showPlayAction;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: AppResponsive.value(100, tablet: 120),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (hasPrimaryActions)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showInstallAction)
                  _SearchGameActionButton(
                    icon: Icons.file_download_outlined,
                    onTap: onInstallTap,
                  ),
                if (showInstallAction && showPlayAction)
                  Gap(AppResponsive.space(8)),
                if (showPlayAction)
                  _SearchGameActionButton(
                    icon: Icons.play_arrow_rounded,
                    onTap: onPlayTap,
                  ),
              ],
            ),
          if (showSubscribeAction) ...[
            if (hasPrimaryActions) Gap(AppResponsive.space(8)),
            InkWell(
              onTap: onSubscribeTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppResponsive.space(10),
                  vertical: AppResponsive.space(8),
                ),
                decoration: BoxDecoration(
                  color: AppColors.colorF8AB0F,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      Assets.svg.icSubscribe,
                      width: AppResponsive.space(12),
                      height: AppResponsive.space(12),
                    ),
                    Gap(AppResponsive.space(6)),
                    Text(
                      'Subscribe',
                      style: poppinsW600.copyWith(
                        fontSize: AppResponsive.font(10),
                        color: AppColors.color00002F,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GameTag extends StatelessWidget {
  const _GameTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.space(8),
        vertical: AppResponsive.space(3),
      ),
      decoration: BoxDecoration(
        color: AppColors.color2C175B,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: poppinsW400.copyWith(
          fontSize: AppResponsive.font(10),
          color: AppColors.colorD5CCF2,
        ),
      ),
    );
  }
}
