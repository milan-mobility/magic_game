import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/api/api_end_points.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/data/repositories/api_repo.dart';
import 'package:magic_games/helpers/services/auth_service.dart';
import 'package:magic_games/helpers/services/google_leaderboard_service.dart';
import 'package:magic_games/helpers/services/premium_access_service.dart';
import 'package:magic_games/helpers/services/remote_config.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/utils/connection.dart';
import 'package:magic_games/view/base/app_update_dialog.dart';
import 'package:magic_games/view/base/appupgrader/upgrader/upgrade_messages.dart';
import 'package:magic_games/view/base/appupgrader/upgrader/upgrader.dart';
import 'package:magic_games/view/base/custom_snack_bar.dart';
import 'package:magic_games/view/screens/home/widgets/sections/home_section_config.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends GetxController implements GetxService {
  HomeController(this.apiRepo)
    : _upgrader = Upgrader(
        canDismissDialog: false,
        debugLogging: false,
        showIgnore: false,
        showLater: false,
        showReleaseNotes: false,
      );

  final ApiRepo apiRepo;
  final Upgrader _upgrader;
  final AuthService _authService = Get.find<AuthService>();
  final PremiumAccessService _premiumAccessService =
      Get.find<PremiumAccessService>();
  final SharedPreferenceHelper _sharedPreferenceHelper =
      Get.find<SharedPreferenceHelper>();

  final Rx<GameModel?> gameModel = Rx<GameModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasPremiumAccess = false.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString signedInUserEmail = ''.obs;
  final RxList<Games> recentPlayedGames = <Games>[].obs;
  StreamSubscription<UpgraderEvaluateNeed>? _upgradeSubscription;
  StreamSubscription<User?>? _authSubscription;
  Worker? _premiumAccessWorker;
  bool _isUpgradeDialogVisible = false;

  @override
  void onInit() {
    super.onInit();
    hasPremiumAccess.value = _premiumAccessService.hasPremiumAccess;
    _syncSignedInUserEmail();
    _premiumAccessWorker = ever<bool>(
      _premiumAccessService.hasPremiumAccessRx,
      (final bool value) {
        hasPremiumAccess.value = value;
      },
    );
    _authSubscription = _authService.authStateChanges().listen((_) {
      _syncSignedInUserEmail();
    });

    GoogleLeaderboardService.instance.signIn();
    _syncPremiumAccess();
    fetchGames();
  }

  @override
  void onReady() {
    super.onReady();
    _initializeUpgradeCheck();
  }

  @override
  void onClose() {
    _upgradeSubscription?.cancel();
    _authSubscription?.cancel();
    _premiumAccessWorker?.dispose();
    _upgrader.dispose();
    super.onClose();
  }

  Future<void> fetchGames() async {
    await _syncPremiumAccess();

    final bool isInternetAvailable = await ConnectionUtils.isNetworkConnected();
    if (!isInternetAvailable) {
      return;
    }

    await _loadGames();
  }

  Future<void> reloadForLanguageChange() async {
    selectedCategoryId.value = '';
    recentPlayedGames.clear();
    gameModel.value = null;
    await fetchGames();
  }

  Future<void> _loadGames() async {
    try {
      isLoading.value = true;
      gameModel.value = await apiRepo.getGames();
      final String? defaultCategoryId = _defaultCategoryIdFromModel(
        gameModel.value,
      );
      if (_hasText(defaultCategoryId)) {
        selectedCategoryId.value = defaultCategoryId!;
      }
      _refreshRecentlyPlayedGames();
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
          iconUrl: _normalizeCategoryImageUrl(category.url),
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

  Set<int> get comingSoonGameIds {
    return homeSections
        .where(
          (final HomeSectionData section) => section.showHourglassIndicator,
        )
        .expand((final HomeSectionData section) => section.games)
        .map((final Games game) => game.id)
        .whereType<int>()
        .toSet();
  }

  Future<void> recordRecentlyPlayedGame(final Games game) async {
    final String? gameKey = _recentlyPlayedKeyForGame(game);
    if (!_hasText(gameKey)) {
      return;
    }

    await _sharedPreferenceHelper.addRecentlyPlayedGameKey(gameKey!);
    _refreshRecentlyPlayedGames();
  }

  void refreshRecentlyPlayedGames() {
    _refreshRecentlyPlayedGames();
  }

  void selectCategory(final String categoryId) {
    selectedCategoryId.value = categoryId;
  }

  Future<void> openStoreForGame(final Games game) async {
    final String? storeUrl = _platformStoreUrl(game);
    if (!_hasText(storeUrl)) {
      showErrorSnackBar(
        title: 'Store unavailable'.tr,
        message: GetPlatform.isIOS
            ? 'Add the iOS store URL key for this game to enable redirection.'
                  .tr
            : 'Store URL is not available for this game.'.tr,
      );
      return;
    }

    final Uri? uri = Uri.tryParse(
      'https://play.google.com/store/apps/details?id=${storeUrl!}',
    );
    if (uri == null) {
      showErrorSnackBar(
        title: 'Invalid store URL'.tr,
        message: 'This game has an invalid store redirect link.'.tr,
      );
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void openGame(final Games game) {
    Get.toNamed(
      RouteHelper.gameDetail,
      arguments: <String, dynamic>{'game': game},
    );
  }

  bool requiresSubscriptionForGame(final Games game) {
    return (game.subscription ?? false) && !hasPremiumAccess.value;
  }

  Future<void> _syncPremiumAccess() async {
    await _premiumAccessService.refreshPremiumAccess();
    hasPremiumAccess.value = _premiumAccessService.hasPremiumAccess;
  }

  void _refreshRecentlyPlayedGames() {
    final GameModel? model = gameModel.value;
    if (model == null) {
      recentPlayedGames.clear();
      return;
    }

    final Map<String, Games> gamesByKey = <String, Games>{};
    for (final Games game in _catalogGames(model)) {
      final String? gameKey = _recentlyPlayedKeyForGame(game);
      if (!_hasText(gameKey) || gamesByKey.containsKey(gameKey)) {
        continue;
      }

      gamesByKey[gameKey!] = game;
    }

    final List<Games> orderedGames = _sharedPreferenceHelper
        .recentlyPlayedGameKeys
        .map((final String key) => gamesByKey[key])
        .whereType<Games>()
        .toList();
    recentPlayedGames.assignAll(orderedGames);
  }

  Future<void> _initializeUpgradeCheck() async {
    await _upgrader.initialize();
    _upgradeSubscription ??= _upgrader.evaluationStream.listen((
      final bool shouldEvaluate,
    ) {
      if (shouldEvaluate) {
        _checkForUpgrade();
      }
    });
    _checkForUpgrade();
  }

  Future<void> _checkForUpgrade() async {
    if (_isUpgradeDialogVisible || (Get.isDialogOpen ?? false)) {
      return;
    }

    if (!_upgrader.shouldDisplayUpgrade()) {
      return;
    }

    await _upgrader.saveLastAlerted();

    _isUpgradeDialogVisible = true;
    await showAppUpdateDialog<void>(
      onUpdate: () async {
        final bool launched = await _launchUpgradeStoreListing();
        if (launched && (Get.isDialogOpen ?? false)) {
          Get.back<void>();
        }
      },
      barrierDismissible: !_upgrader.blocked(),
      title: _upgrader.messages.message(UpgraderMessage.title) ?? 'Update'.tr,
      message: _upgrader.message(),
      buttonLabel:
          _upgrader.messages.message(UpgraderMessage.buttonTitleUpdate) ??
          'Update',
    );
    _isUpgradeDialogVisible = false;
  }

  Future<bool> _launchUpgradeStoreListing() async {
    final String? listingUrl = _upgrader.currentAppStoreListingURL();
    if (listingUrl == null || listingUrl.isEmpty) {
      return false;
    }

    final Uri? uri = Uri.tryParse(listingUrl);
    if (uri == null) {
      return false;
    }

    return launchUrl(
      uri,
      mode: GetPlatform.isAndroid
          ? LaunchMode.externalNonBrowserApplication
          : LaunchMode.platformDefault,
    );
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

  String? _normalizeCategoryImageUrl(final String? value) {
    if (!_hasText(value)) {
      return null;
    }

    final String baseUrl = Get.isRegistered<RemoteConfigService>()
        ? Get.find<RemoteConfigService>().getString(
            RemoteConfigService.baseUrlKey,
            fallback: Endpoints.defaultBaseUrl,
          )
        : Endpoints.defaultBaseUrl;
    final String normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl
        : '$baseUrl/';

    return '$normalizedBaseUrl${value!.trim()}';
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

  List<Games> _catalogGames(final GameModel model) {
    final List<Games> catalogGames = _gamesById(model).values.toList();
    final Set<String> seenKeys = catalogGames
        .map(_recentlyPlayedKeyForGame)
        .whereType<String>()
        .toSet();

    for (final HomeFeaturedBannerData bannerData in featuredBanners) {
      final Games game = bannerData.game;
      final String? gameKey = _recentlyPlayedKeyForGame(game);
      if (!_hasText(gameKey) || seenKeys.contains(gameKey)) {
        continue;
      }

      seenKeys.add(gameKey!);
      catalogGames.add(game);
    }

    return catalogGames;
  }

  String? _recentlyPlayedKeyForGame(final Games? game) {
    if (game?.id != null) {
      return 'game_${game!.id}';
    }

    final String? gameUrl = _normalizeText(game?.gameurl);
    if (_hasText(gameUrl)) {
      return gameUrl;
    }

    return _normalizeText(game?.name);
  }

  HomeSectionData? _buildHomeSection(
    final Sections section,
    final GameModel model,
    final Map<int, Games> gamesById,
  ) {
    if (!_canShowSection(section)) {
      return null;
    }

    final HomeSectionConfig? config = _resolveSectionConfig(section);
    if (config != null && !config.isVisible) {
      return null;
    }

    final HomeSectionLayoutType resolvedLayoutType = _resolveSectionLayoutType(
      section,
      model.sectiontype,
    );
    final String? normalizedSectionId = _normalizeText(section.id);
    final String? normalizedSectionType = _normalizeText(section.type);
    final bool showHourglassIndicator =
        normalizedSectionId == '207' || normalizedSectionType == '207';
    final HomeSectionLayoutType layoutType = showHourglassIndicator
        ? HomeSectionLayoutType.iconWithBanner
        : resolvedLayoutType;
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
      showHourglassIndicator: showHourglassIndicator,
      showViewAll: section.type != '205',
      sortOrder: config?.sortOrder ?? 999,
      games: games,
      collections: collections,
    );
  }

  bool _canShowSection(final Sections section) {
    if (_normalizeText(section.type) != '203') {
      return true;
    }

    final List<String> allowedEmails = (section.emails ?? <String>[])
        .map((final String value) => value.trim().toLowerCase())
        .where((final String value) => value.isNotEmpty)
        .toList();
    if (allowedEmails.isEmpty) {
      return false;
    }

    final String normalizedSignedInEmail = signedInUserEmail.value
        .trim()
        .toLowerCase();
    if (normalizedSignedInEmail.isEmpty) {
      return false;
    }

    return allowedEmails.contains(normalizedSignedInEmail);
  }

  HomeSectionLayoutType _resolveSectionLayoutType(
    final Sections section,
    final Sectiontype? sectiontype,
  ) {
    if (section.type == '206') {
      return HomeSectionLayoutType.iconWithBannerDownload;
    }

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
      case 'iconwithbannerdownload':
        return HomeSectionLayoutType.iconWithBannerDownload;
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
            categoryId: banner.category?.toString(),
            // Type 205 collection cards should always use the footer banner image.
            imageUrl: _normalizeText(banner.bannerurl),
          ),
        )
        .where((final HomeCollectionCardData card) => _hasText(card.title))
        .toList();
  }

  void openSearch({String? selectedCategoryId}) {
    Get.toNamed(
      RouteHelper.searchGames,
      arguments: <String, dynamic>{
        'categories': homeCategories,
        'games': allGames,
        'comingSoonGameIds': comingSoonGameIds.toList(growable: false),
        if (_hasText(selectedCategoryId))
          'selectedCategoryId': selectedCategoryId,
      },
    );
  }

  void openCollectionSearch(final HomeCollectionCardData collection) {
    openSearch(selectedCategoryId: collection.categoryId);
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

    return 'Collection'.tr;
  }

  String _resolveCollectionSubtitle(
    final FooterBanner banner,
    final String? fallbackSubtitle,
  ) {
    final String? subtitle = _normalizeText(banner.desc);
    if (subtitle != null) {
      return subtitle;
    }

    return _normalizeText(fallbackSubtitle) ?? 'Explore games'.tr;
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

    return 'Games'.tr;
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

  void _syncSignedInUserEmail() {
    signedInUserEmail.value = (_authService.currentUser?.email ?? '')
        .trim()
        .toLowerCase();
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
    required this.showHourglassIndicator,
    required this.showViewAll,
    required this.sortOrder,
    required this.games,
    required this.collections,
  });

  final String id;
  final String title;
  final String? subtitle;
  final HomeSectionLayoutType layoutType;
  final bool showHourglassIndicator;
  final bool showViewAll;
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
    this.categoryId,
  });

  final String title;
  final String subtitle;
  final String? leadingLabel;
  final String? imageUrl;
  final String? categoryId;
}

enum HomeSectionLayoutType {
  banner,
  iconWithIcon,
  iconWithBanner,
  iconWithBannerDownload,
  icon,
  collection,
}
