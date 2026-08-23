import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/services/premium_access_service.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/utils/utility.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';

class SearchGameController extends GetxController {
  SearchGameController();

  final PremiumAccessService _premiumAccessService =
      Get.find<PremiumAccessService>();

  final TextEditingController txtSearch = TextEditingController();

  List<HomeCategoryData> categories = <HomeCategoryData>[];
  List<Games> allGames = <Games>[];
  List<Games> filteredGames = <Games>[];
  Set<int> comingSoonGameIds = <int>{};

  String selectedCategoryId = '';

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      final dynamic rawCategories = Get.arguments['categories'];
      final dynamic rawGames = Get.arguments['games'];
      final dynamic rawComingSoonGameIds = Get.arguments['comingSoonGameIds'];
      final dynamic rawSelectedCategoryId = Get.arguments['selectedCategoryId'];

      categories = rawCategories is List
          ? rawCategories.cast<HomeCategoryData>()
          : <HomeCategoryData>[];
      allGames = rawGames is List ? rawGames.cast<Games>() : <Games>[];
      comingSoonGameIds = rawComingSoonGameIds is List
          ? rawComingSoonGameIds
                .map(
                  (final dynamic value) =>
                      value is int ? value : int.tryParse(value.toString()),
                )
                .whereType<int>()
                .toSet()
          : <int>{};

      if (rawSelectedCategoryId is String &&
          rawSelectedCategoryId.trim().isNotEmpty) {
        selectedCategoryId = rawSelectedCategoryId.trim();
      }
    }

    selectedCategoryId = _resolvedInitialCategoryId();

    txtSearch.addListener(_applyFilters);
    _applyFilters();
  }

  void selectCategory(final String categoryId) {
    selectedCategoryId = categoryId;
    _applyFilters();
  }

  void openGame(final Games game) {
    Get.toNamed(
      RouteHelper.gameDetailRoute(game),
      arguments: <String, dynamic>{'game': game},
    );
  }

  Future<void> onPrimaryActionTap(final Games game) async {
    if (shouldShowInstall(game)) {
      await openStoreForGame(game);
      return;
    }

    await onPlayTap(game);
  }

  bool shouldShowInstall(final Games game) {
    if (requiresSubscriptionForGame(game)) {
      return false;
    }

    return game.install == true;
  }

  bool shouldShowPlay(final Games game) {
    if (requiresSubscriptionForGame(game)) {
      return false;
    }

    return game.play == true;
  }

  bool shouldShowSubscribe(final Games game) =>
      requiresSubscriptionForGame(game);

  bool shouldShowHourglass(final Games game) {
    final int? gameId = game.id;
    if (gameId == null) {
      return false;
    }

    return comingSoonGameIds.contains(gameId);
  }

  bool requiresSubscriptionForGame(final Games game) {
    return (game.subscription ?? false) &&
        !_premiumAccessService.hasPremiumAccess;
  }

  Future<void> onPlayTap(final Games game) async {
    if (requiresSubscriptionForGame(game)) {
      onSubscribeTap();
      return;
    }

    openGame(game);
  }

  void onSubscribeTap() {
    Get.offAllNamed(RouteHelper.vip);
  }

  Future<void> openStoreForGame(final Games game) async {
    final String? storeUrl = _platformStoreUrl(game);
    if (!_hasText(storeUrl)) {
      return;
    }

    await Utility.openGameStoreListing(storeUrl!);
  }

  void _applyFilters() {
    final String query = txtSearch.text.trim().toLowerCase();
    final HomeCategoryData? selectedCategory = categories.firstWhereOrNull(
      (final HomeCategoryData item) => item.id == selectedCategoryId,
    );

    filteredGames = allGames.where((final Games game) {
      final bool matchesCategory = _matchesSelectedCategory(
        game: game,
        selectedCategoryId: selectedCategoryId,
        selectedCategoryName: selectedCategory?.title,
      );
      if (!matchesCategory) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final String searchable = <String?>[
        game.name,
        game.shortname,
        game.categoryName,
        game.badge,
        game.keyword,
      ].whereType<String>().join(' ').toLowerCase();

      return searchable.contains(query);
    }).toList();
    update();
  }

  bool _matchesSelectedCategory({
    required final Games game,
    required final String selectedCategoryId,
    final String? selectedCategoryName,
  }) {
    if (!_hasText(selectedCategoryId) ||
        selectedCategoryId == _defaultCategoryId) {
      return true;
    }

    final Set<String> candidateValues = <String>{
      ..._tokenizeCategoryValues(game.category),
      ..._tokenizeCategoryValues(game.categoryName),
    };

    if (candidateValues.contains(selectedCategoryId.toLowerCase())) {
      return true;
    }

    if (_hasText(selectedCategoryName)) {
      return candidateValues.contains(
        selectedCategoryName!.trim().toLowerCase(),
      );
    }

    return false;
  }

  Set<String> _tokenizeCategoryValues(final String? value) {
    if (!_hasText(value)) {
      return const <String>{};
    }

    return value!
        .split(RegExp(r'[,|/]'))
        .map((final String item) => item.trim().toLowerCase())
        .where((final String item) => item.isNotEmpty)
        .toSet();
  }

  String? _platformStoreUrl(final Games game) {
    if (GetPlatform.isAndroid) {
      return _normalizeText(game.storeurl);
    }

    return _normalizeText(game.storeurl);
  }

  String? _normalizeText(final String? value) {
    if (!_hasText(value)) {
      return null;
    }

    return value!.trim();
  }

  bool _hasText(final String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  String get _defaultCategoryId {
    if (categories.isEmpty) {
      return '';
    }

    return categories.first.id;
  }

  String _resolvedInitialCategoryId() {
    if (_hasText(selectedCategoryId) &&
        categories.any(
          (final HomeCategoryData item) => item.id == selectedCategoryId,
        )) {
      return selectedCategoryId;
    }

    return _defaultCategoryId;
  }

  @override
  void onClose() {
    txtSearch.dispose();
    super.onClose();
  }
}
