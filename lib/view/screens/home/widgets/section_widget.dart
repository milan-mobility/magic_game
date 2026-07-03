import 'package:flutter/material.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/home/widgets/game_card_widget.dart';

class SectionWidget extends StatelessWidget {
  const SectionWidget({super.key, required this.section, this.onGameTap});

  final Sections section;
  final void Function(Games game)? onGameTap;

  @override
  Widget build(BuildContext context) {
    final games = section.games;
    if (games == null || games.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title ?? '',
                  style: dmSansW700.copyWith(
                    fontSize: AppResponsive.font(18),
                    color: AppColors.color242424,
                  ),
                ),
                if (section.subtitle != null && section.subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    section.subtitle!,
                    style: dmSansW400.copyWith(
                      fontSize: AppResponsive.font(13),
                      color: AppColors.color787878,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: AppResponsive.value(220, tablet: 270),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: games.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) => GameCardWidget(
                game: games[index],
                onTap: () => onGameTap?.call(games[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
