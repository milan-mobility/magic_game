import 'package:get/get.dart';

class ProfileController extends GetxController {
  final String playerName = 'Guest Player';
  final String playerType = 'Guest';
  final String description =
      'Play games, ear achievement and\nsave your progress';

  final List<ProfileStatData> stats = const <ProfileStatData>[
    ProfileStatData(
      value: '24',
      label: 'Game Played',
      iconAsset: 'assets/svg/ic_total_game.svg',
    ),
    ProfileStatData(
      value: '128',
      label: 'Achievement',
      iconAsset: 'assets/svg/ic_profile_star.svg',
    ),
    ProfileStatData(
      value: '12',
      label: 'Favorites',
      iconAsset: 'assets/svg/ic_fvrt.svg',
    ),
  ];

  void onEditTap() {}

  void onLogoutTap() {}
}

class ProfileStatData {
  const ProfileStatData({
    required this.value,
    required this.label,
    required this.iconAsset,
  });

  final String value;
  final String label;
  final String iconAsset;
}
