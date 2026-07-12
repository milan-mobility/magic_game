import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/data/repositories/api_repo.dart';
import 'package:magic_games/helpers/extensions/string_ext.dart';
import 'package:magic_games/utils/connection.dart';
import 'package:magic_games/utils/message_constant.dart';
import 'package:magic_games/view/base/custom_snack_bar.dart';
import 'package:magic_games/view/screens/home/widgets/sections/home_section_config.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends GetxController implements GetxService {
  HomeController(this.apiRepo);

  final ApiRepo apiRepo;

  final Rx<GameModel?> gameModel = Rx<GameModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString selectedCategoryId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGames();
  }

  Future<void> fetchGames() async {
    final bool isInternetAvailable = await ConnectionUtils.isNetworkConnected();
    if (!isInternetAvailable) {
      showErrorSnackBar(
        title: MessageConstant.netWorkTitle,
        message: MessageConstant.networkError,
      );
      return;
    }

    try {
      isLoading.value = true;
      gameModel.value = await apiRepo.getGames();
      final String? defaultCategoryId = _defaultCategoryIdFromModel(
        gameModel.value,
      );
      if (_hasText(defaultCategoryId)) {
        selectedCategoryId.value = defaultCategoryId!;
      }
    } catch (e) {
      debugPrint('EXCEPTION=>${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  List<HomeCategoryData> get homeCategories {
    final List<HomeCategoryData> categories = <HomeCategoryData>[];
    final Set<String> seenIds = <String>{};

    for (final Gamecategory category
        in gameModel.value?.gamecategory ?? <Gamecategory>[]) {
      final MapEntry<String, String>? entry = _categoryEntry(category);
      if (entry == null || !seenIds.add(entry.key)) {
        continue;
      }

      categories.add(
        HomeCategoryData(
          id: entry.key,
          title: entry.value,
          iconUrl: _normalizeImageUrl(category.url),
        ),
      );
    }

    return categories;
  }

  List<HomeFeaturedBannerData> get featuredBanners {
    final GameModel? model = gameModel.value;
    if (model == null) {
      return const <HomeFeaturedBannerData>[];
    }

    final Map<int, Games> gamesById = _gamesById(model);

    return (model.featuredbanner ?? <Featuredbanner>[])
        .map(
          (final Featuredbanner banner) => HomeFeaturedBannerData(
            banner: banner,
            badge: _findBannerBadge(banner.badgeid, model.featurebannerbagde),
            game:
                gamesById[banner.id] ?? _mapFeaturedBannerToGame(banner, model),
          ),
        )
        .toList();
  }

  List<Games> get allGames {
    final GameModel? model = gameModel.value;
    if (model == null) {
      return const <Games>[];
    }

    return _gamesById(model).values.toList();
  }

  List<HomeSectionData> get homeSections {
    final GameModel? model = gameModel.value;
    if (model == null) {
      return const <HomeSectionData>[];
    }

    final Map<int, Games> gamesById = _gamesById(model);

    return (model.sections ?? <Sections>[])
        .map(
          (final Sections section) =>
              _buildHomeSection(section, model, gamesById),
        )
        .whereType<HomeSectionData>()
        .toList()
      ..sort(
        (final HomeSectionData first, final HomeSectionData second) =>
            first.sortOrder.compareTo(second.sortOrder),
      );
  }

  void selectCategory(final String categoryId) {
    selectedCategoryId.value = categoryId;
  }

  Future<void> openStoreForGame(final Games game) async {
    final String? storeUrl = _platformStoreUrl(game);
    if (!_hasText(storeUrl)) {
      showErrorSnackBar(
        title: 'Store unavailable',
        message: GetPlatform.isIOS
            ? 'Add the iOS store URL key for this game to enable redirection.'
            : 'Store URL is not available for this game.',
      );
      return;
    }

    final Uri? uri = Uri.tryParse(
      'https://play.google.com/store/apps/details?id=${storeUrl!}',
    );
    if (uri == null) {
      showErrorSnackBar(
        title: 'Invalid store URL',
        message: 'This game has an invalid store redirect link.',
      );
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void openGame(final Games game) {
    Get.toNamed('/gameDetail', arguments: <String, dynamic>{'game': game});
  }

  MapEntry<String, String>? _categoryEntry(final Gamecategory category) {
    final String? id = _normalizeText(category.id);
    final String? name = _normalizeText(category.name);

    if (id == null || name == null) {
      return null;
    }

    return MapEntry<String, String>(id, name);
  }

  String? _defaultCategoryIdFromModel(final GameModel? model) {
    for (final Gamecategory category
        in model?.gamecategory ?? <Gamecategory>[]) {
      final MapEntry<String, String>? entry = _categoryEntry(category);
      if (entry != null) {
        return entry.key;
      }
    }

    return null;
  }

  Featurebannerbagde? _findBannerBadge(
    final String? badgeId,
    final List<Featurebannerbagde>? badges,
  ) {
    final int? parsedBadgeId = int.tryParse(badgeId ?? '');
    if (parsedBadgeId == null) {
      return null;
    }

    for (final Featurebannerbagde badge in badges ?? <Featurebannerbagde>[]) {
      if (badge.id == parsedBadgeId) {
        return badge;
      }
    }

    return null;
  }

  Map<String, String> _categoryNamesById(final List<Gamecategory>? categories) {
    final Map<String, String> values = <String, String>{};

    for (final Gamecategory category in categories ?? <Gamecategory>[]) {
      final MapEntry<String, String>? entry = _categoryEntry(category);
      if (entry != null) {
        values[entry.key] = entry.value;
      }
    }

    return values;
  }

  Map<int, Games> _gamesById(final GameModel model) {
    final Map<String, String> categoryNamesById = _categoryNamesById(
      model.gamecategory,
    );

    return <int, Games>{
      for (final Games game in model.games ?? <Games>[])
        if (game.id != null)
          game.id!: _gameWithResolvedCategoryName(game, categoryNamesById),
    };
  }

  Games _gameWithResolvedCategoryName(
    final Games game,
    final Map<String, String> categoryNamesById,
  ) {
    return Games(
      id: game.id,
      name: game.name,
      shortname: game.shortname,
      banner: game.banner,
      icon: game.icon,
      gameurl: game.gameurl,
      storeurl: game.storeurl,
      category: game.category,
      categoryName: _resolvedCategoryName(
        game.category,
        game.categoryName,
        categoryNamesById,
      ),
      orientation: game.orientation,
      rating: game.rating,
      badge: game.badge,
      subscription: game.subscription,
      play: game.play,
      install: game.install,
      interstitialid: game.interstitialid,
      rewardid: game.rewardid,
      keyword: game.keyword,
      shortdesc: game.shortdesc,
    );
  }

  Games _mapFeaturedBannerToGame(
    final Featuredbanner banner,
    final GameModel model,
  ) {
    final Map<String, String> categoryNamesById = _categoryNamesById(
      model.gamecategory,
    );
    return Games(
      id: banner.id,
      name: banner.name,
      shortname: banner.shortname,
      banner: banner.banner,
      icon: banner.icon,
      gameurl: banner.gameurl,
      storeurl: banner.storeurl,
      category: banner.category,
      categoryName: _resolvedCategoryName(
        banner.category,
        banner.categoryName,
        categoryNamesById,
      ),
      orientation: banner.orientation,
      rating: banner.rating,
      badge: banner.tag,
      subscription: banner.subscription,
      play: banner.play,
      install: banner.install,
      interstitialid: banner.interstitialid,
      rewardid: banner.rewardid,
      keyword: banner.keyword,
      shortdesc: banner.desc,
    );
  }

  String? _resolvedCategoryName(
    final String? categoryIdValue,
    final String? fallbackCategoryName,
    final Map<String, String> categoryNamesById,
  ) {
    final List<String> names = _tokenizeCategoryValues(categoryIdValue)
        .map((final String id) => categoryNamesById[id])
        .whereType<String>()
        .toList();

    if (names.isNotEmpty) {
      return names.join(', ');
    }

    return _normalizeText(fallbackCategoryName);
  }

  String? _normalizeImageUrl(final String? value) {
    if (!_hasText(value)) {
      return null;
    }

    return value!.imageUrl();
  }

  String? _platformStoreUrl(final Games game) {
    if (GetPlatform.isAndroid) {
      return _normalizeText(game.storeurl);
    }

    if (GetPlatform.isIOS) {
      // TODO(milan): replace this with the dedicated iOS store field once it is
      // added to the game model and API response.
      return null;
    }

    return _normalizeText(game.storeurl);
  }

  HomeSectionData? _buildHomeSection(
    final Sections section,
    final GameModel model,
    final Map<int, Games> gamesById,
  ) {
    final HomeSectionConfig? config = _resolveSectionConfig(section);
    if (config != null && !config.isVisible) {
      return null;
    }

    final HomeSectionLayoutType layoutType = _resolveSectionLayoutType(
      section,
      model.sectiontype,
    );
    final String? selectedCategoryIdValue = _normalizeText(
      selectedCategoryId.value,
    );
    final String? selectedCategoryName = _categoryNameForId(
      int.tryParse(selectedCategoryIdValue ?? ''),
      model.gamecategory,
    );

    final List<Games> games = (section.games ?? <int>[])
        .map((final int gameId) => gamesById[gameId])
        .whereType<Games>()
        .where(
          (final Games game) => _matchesSelectedCategory(
            gameCategoryId: game.category,
            gameCategoryName: game.categoryName,
            selectedCategoryId: selectedCategoryIdValue,
            selectedCategoryName: selectedCategoryName,
          ),
        )
        .toList();
    final List<HomeCollectionCardData> collections = _buildCollectionCards(
      section,
      model,
      selectedCategoryIdValue,
    );

    if (layoutType == HomeSectionLayoutType.collection &&
        collections.isEmpty &&
        games.isEmpty) {
      return null;
    }

    if (layoutType != HomeSectionLayoutType.collection && games.isEmpty) {
      return null;
    }

    return HomeSectionData(
      id: section.id ?? section.type ?? '',
      title: _resolveSectionTitle(section, model.sectiontype, config),
      subtitle: _resolveSectionSubtitle(section, config),
      layoutType: layoutType,
      sortOrder: config?.sortOrder ?? 999,
      games: games,
      collections: collections,
    );
  }

  HomeSectionLayoutType _resolveSectionLayoutType(
    final Sections section,
    final Sectiontype? sectiontype,
  ) {
    final String normalizedType = _normalizeSectionLayoutLabel(
      sectiontype?.labelForType(section.type),
    );

    switch (normalizedType) {
      case 'banner':
        return HomeSectionLayoutType.banner;
      case 'iconwithicon':
        return HomeSectionLayoutType.iconWithIcon;
      case 'iconwithbanner':
        return HomeSectionLayoutType.iconWithBanner;
      case 'icon':
        return HomeSectionLayoutType.icon;
      case 'collection':
        return HomeSectionLayoutType.collection;
      default:
        return HomeSectionLayoutType.iconWithIcon;
    }
  }

  String _normalizeSectionLayoutLabel(final String? value) {
    if (!_hasText(value)) {
      return '';
    }

    return value!.trim().toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  }

  List<HomeCollectionCardData> _buildCollectionCards(
    final Sections section,
    final GameModel model,
    final String? selectedCategoryId,
  ) {
    return (section.footerBanner ?? <FooterBanner>[])
        .where(
          (final FooterBanner banner) => _matchesSelectedCategory(
            gameCategoryId: banner.category?.toString(),
            selectedCategoryId: selectedCategoryId,
            selectedCategoryName: _categoryNameForId(
              banner.category,
              model.gamecategory,
            ),
          ),
        )
        .map(
          (final FooterBanner banner) => HomeCollectionCardData(
            title: _resolveCollectionTitle(
              banner,
              _categoryNameForId(banner.category, model.gamecategory),
            ),
            subtitle: _resolveCollectionSubtitle(banner, section.subtitle),
            leadingLabel: _normalizeText(banner.badge),
            // Type 205 collection cards should always use the footer banner image.
            imageUrl: _normalizeText(banner.bannerurl),
          ),
        )
        .where((final HomeCollectionCardData card) => _hasText(card.title))
        .toList();
  }

  bool _matchesSelectedCategory({
    required final String? selectedCategoryId,
    final String? selectedCategoryName,
    final String? gameCategoryId,
    final String? gameCategoryName,
  }) {
    if (!_hasText(selectedCategoryId) ||
        selectedCategoryId == _defaultCategoryIdFromModel(gameModel.value)) {
      return true;
    }

    final Set<String> candidateValues = <String>{
      ..._tokenizeCategoryValues(gameCategoryId),
      ..._tokenizeCategoryValues(gameCategoryName),
    };

    if (candidateValues.contains(selectedCategoryId!.trim().toLowerCase())) {
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

  String _resolveCollectionTitle(
    final FooterBanner banner,
    final String? categoryName,
  ) {
    if (_hasText(banner.tag)) {
      return banner.tag!.trim();
    }

    if (_hasText(categoryName) && _hasText(banner.badge)) {
      return '${categoryName!.trim()} ${banner.badge!.trim()}';
    }

    if (_hasText(categoryName)) {
      return categoryName!.trim();
    }

    if (_hasText(banner.badge)) {
      return banner.badge!.trim();
    }

    return 'Collection';
  }

  String _resolveCollectionSubtitle(
    final FooterBanner banner,
    final String? fallbackSubtitle,
  ) {
    final String? subtitle = _normalizeText(banner.desc);
    if (subtitle != null) {
      return subtitle;
    }

    return _normalizeText(fallbackSubtitle) ?? 'Explore games';
  }

  String? _categoryNameForId(
    final int? categoryId,
    final List<Gamecategory>? categories,
  ) {
    if (categoryId == null) {
      return null;
    }

    for (final Gamecategory category in categories ?? <Gamecategory>[]) {
      final MapEntry<String, String>? entry = _categoryEntry(category);
      if (entry?.key == '$categoryId') {
        return entry!.value;
      }
    }

    return null;
  }

  HomeSectionConfig? _resolveSectionConfig(final Sections section) {
    return HomeSectionConfigs.sections[section.id] ??
        HomeSectionConfigs.sections[section.type];
  }

  String _resolveSectionTitle(
    final Sections section,
    final Sectiontype? sectiontype,
    final HomeSectionConfig? config,
  ) {
    if (_hasText(config?.title)) {
      return config!.title!.trim();
    }

    if (_hasText(section.title)) {
      return section.title!.trim();
    }

    final String? fallbackTitle = sectiontype?.labelForType(section.type);
    if (_hasText(fallbackTitle)) {
      return fallbackTitle!.trim();
    }

    return 'Games';
  }

  String? _resolveSectionSubtitle(
    final Sections section,
    final HomeSectionConfig? config,
  ) {
    if (_hasText(config?.subtitle)) {
      return config!.subtitle!.trim();
    }

    return _normalizeText(section.subtitle);
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
}

class HomeSectionData {
  const HomeSectionData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.layoutType,
    required this.sortOrder,
    required this.games,
    required this.collections,
  });

  final String id;
  final String title;
  final String? subtitle;
  final HomeSectionLayoutType layoutType;
  final int sortOrder;
  final List<Games> games;
  final List<HomeCollectionCardData> collections;
}

class HomeCategoryData {
  const HomeCategoryData({
    required this.id,
    required this.title,
    required this.iconUrl,
  });

  final String id;
  final String title;
  final String? iconUrl;
}

class HomeFeaturedBannerData {
  const HomeFeaturedBannerData({
    required this.banner,
    required this.badge,
    required this.game,
  });

  final Featuredbanner banner;
  final Featurebannerbagde? badge;
  final Games game;
}

class HomeCollectionCardData {
  const HomeCollectionCardData({
    required this.title,
    required this.subtitle,
    required this.leadingLabel,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String? leadingLabel;
  final String? imageUrl;
}

enum HomeSectionLayoutType {
  banner,
  iconWithIcon,
  iconWithBanner,
  icon,
  collection,
}
