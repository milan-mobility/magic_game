import 'package:flutter/material.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';

class FeaturedBannerWidget extends StatelessWidget {
  const FeaturedBannerWidget({super.key, required this.game});

  final Games game;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (game.image != null)
          Image.network(
            game.image!,
            width: double.infinity,
            height: AppResponsive.value(220, tablet: 300),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Row(
              children: [
                if (game.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      game.image!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    game.name ?? '',
                    style: dmSansW700.copyWith(
                      color: AppColors.white,
                      fontSize: AppResponsive.font(18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
