import 'package:flutter/material.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';

class GameCardWidget extends StatelessWidget {
  const GameCardWidget({super.key, required this.game, this.onTap});

  final Games game;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: AppResponsive.value(160, tablet: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: game.image != null
                      ? Image.network(
                          game.image!,
                          width: AppResponsive.value(160, tablet: 200),
                          height: AppResponsive.value(120, tablet: 150),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                if (game.badge != null && game.badge!.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.colorFF383C,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        game.badge!,
                        style: dmSansW700.copyWith(
                          color: AppColors.white,
                          fontSize: AppResponsive.font(10),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              game.name ?? '',
              style: dmSansW600.copyWith(fontSize: AppResponsive.font(13)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (game.buttonText != null && game.buttonText!.isNotEmpty) ...[
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.color2E7D32,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    game.buttonText!,
                    style: dmSansW600.copyWith(
                      color: AppColors.white,
                      fontSize: AppResponsive.font(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: AppResponsive.value(160, tablet: 200),
      height: AppResponsive.value(120, tablet: 150),
      decoration: BoxDecoration(
        color: AppColors.colorE0E0E0,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
