import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:magic_games/view/screens/home/controller/home_controller.dart';

class SearchGameController extends GetxController {
  SearchGameController();

  final TextEditingController txtSearch = TextEditingController();

  List<HomeCategoryData> categories = <HomeCategoryData>[];
  List<Games> allGames = <Games>[];
  List<Games> filteredGames = <Games>[];

  String selectedCategoryId = '';

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      final dynamic rawCategories = Get.arguments['categories'];
      final dynamic rawGames = Get.arguments['games'];

      categories = rawCategories is List
          ? rawCategories.cast<HomeCategoryData>()
          : <HomeCategoryData>[];
      allGames = rawGames is List ? rawGames.cast<Games>() : <Games>[];
    }

    selectedCategoryId = _defaultCategoryId;

    txtSearch.addListener(_applyFilters);
    _applyFilters();
  }

  void selectCategory(final String categoryId) {
    selectedCategoryId = categoryId;
    _applyFilters();
  }

  void openGame(final Games game) {
    Get.toNamed(
      RouteHelper.gameDetail,
      arguments: <String, dynamic>{'game': game},
    );
  }

  Future<void> onPrimaryActionTap(final Games game) async {
    if (shouldShowInstall(game)) {
      await openStoreForGame(game);
      return;
    }

    openGame(game);
  }

  bool shouldShowInstall(final Games game) => game.install == true;

  bool shouldShowPlay(final Games game) =>
      !shouldShowInstall(game) && game.play == true;

  Future<void> openStoreForGame(final Games game) async {
    final String? storeUrl = _platformStoreUrl(game);
    if (!_hasText(storeUrl)) {
      return;
    }

    final Uri? uri = Uri.tryParse(
      'https://play.google.com/store/apps/details?id=${storeUrl!}',
    );
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
    if (!_hasText(selectedCategoryId) || selectedCategoryId == _defaultCategoryId) {
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

    if (GetPlatform.isIOS) {
      return null;
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

  @override
  void onClose() {
    txtSearch.dispose();
    super.onClose();
  }
}
