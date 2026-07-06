import 'package:flutter/material.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/view/screens/home/widgets/game_cards/game_icon_with_icon.dart';

class GameCardWidget extends StatelessWidget {
  const GameCardWidget({super.key, required this.game, this.onTap});

  final Games game;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GameIconWithIcon(game: game, onTap: onTap);
  }
}
