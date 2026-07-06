import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/extensions/string_ext.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/home/widgets/home_image_placeholder_widget.dart';

//COLLECTION
class GameCollectionItem extends StatelessWidget {
  const GameCollectionItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.leadingLabel,
    this.onTap,
    this.actionText = 'Explore',
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? leadingLabel;
  final VoidCallback? onTap;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    final double cardWidth = AppResponsive.value(286, tablet: 420);
    final double cardHeight = AppResponsive.value(152, tablet: 200);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        // decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackground(cardWidth, cardHeight),

            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const <double>[0.0, 0.1, 1.0],
                  colors: [
                    AppColors.white.withValues(alpha: 0.0),
                    AppColors.colorBC9F84.withValues(alpha: 0.02),
                    AppColors.color7A3F09,
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppResponsive.space(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasText(leadingLabel))
                    Text(
                      leadingLabel!.trim(),
                      style: poppinsW600.copyWith(
                        fontSize: AppResponsive.font(14),
                        color: AppColors.white,
                      ),
                    ),
                  if (_hasText(leadingLabel)) Gap(AppResponsive.space(2)),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: poppinsW700.copyWith(
                      fontSize: AppResponsive.font(18),
                      color: AppColors.white,
                    ),
                  ),
                  Gap(AppResponsive.space(8)),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: poppinsW400.copyWith(
                      fontSize: AppResponsive.font(14),
                      color: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  // _ExploreButton(text: actionText, onTap: onTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(final double cardWidth, final double cardHeight) {
    final String? resolvedUrl = _normalizedUrl(imageUrl.imageUrl());
    // if (resolvedUrl == null) {
    //   return HomeImagePlaceholderWidget(
    //     width: cardWidth,
    //     height: cardHeight,
    //     borderRadius: 15,
    //     iconSize: AppResponsive.space(30),
    //   );
    // }

    return CachedNetworkImage(
      imageUrl: resolvedUrl ?? '',
      imageBuilder:
          (final BuildContext context, final ImageProvider<Object> image) =>
              Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(image: image, fit: BoxFit.cover),
                ),
              ),
      errorWidget: (_, __, ___) => HomeImagePlaceholderWidget(
        width: cardWidth,
        height: cardHeight,
        borderRadius: 15,
        iconSize: AppResponsive.space(30),
      ),
    );
  }

  String? _normalizedUrl(final String? value) {
    if (!_hasText(value)) {
      return null;
    }

    return value!.imageUrl();
  }

  bool _hasText(final String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}

class _ExploreButton extends StatelessWidget {
  const _ExploreButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: AppResponsive.space(16),
            vertical: AppResponsive.space(10),
          ),
          decoration: BoxDecoration(
            color: AppColors.color4B21CA.withOpacity(0.92),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: poppinsW500.copyWith(
                  fontSize: AppResponsive.font(14),
                  color: AppColors.white,
                ),
              ),
              Gap(AppResponsive.space(10)),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.white,
                size: AppResponsive.space(22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
