import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';

class GoogleLeaderboardService {
  GoogleLeaderboardService._();

  static final GoogleLeaderboardService instance = GoogleLeaderboardService._();

  static const String leaderboardId = 'CgkImLX9nZ8YEAIQAQ';
  static const String iosLeaderboardId = 'onegamehighscore';

  bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get _hasLeaderboardId =>
      defaultTargetPlatform != TargetPlatform.iOS ||
      iosLeaderboardId.isNotEmpty;

  Future<bool> signIn() async {
    if (!_isSupportedPlatform) {
      return false;
    }

    try {
      await GameAuth.signIn();

      final bool isSignedIn = await GameAuth.isSignedIn;

      debugPrint('Game services signed in: $isSignedIn');

      return isSignedIn;
    } catch (error, stackTrace) {
      debugPrint('Google Play Games sign-in error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> ensureSignedIn() async {
    if (!_isSupportedPlatform) {
      return false;
    }

    try {
      final bool isSignedIn = await GameAuth.isSignedIn;

      if (isSignedIn) {
        return true;
      }

      return signIn();
    } catch (error) {
      debugPrint('Checking Play Games sign-in failed: $error');
      return false;
    }
  }

  Future<void> submitScore(int score) async {
    if (!_hasLeaderboardId) {
      _logMissingIosLeaderboardId();
      return;
    }

    try {
      final bool isSignedIn = await ensureSignedIn();

      if (!isSignedIn) {
        debugPrint('Score not submitted: player is not signed in.');
        return;
      }

      final result = await Leaderboards.submitScore(
        score: Score(
          androidLeaderboardID: defaultTargetPlatform == TargetPlatform.android
              ? leaderboardId
              : '',
          iOSLeaderboardID: defaultTargetPlatform == TargetPlatform.iOS
              ? iosLeaderboardId
              : '',
          value: score,
        ),
      );

      debugPrint('Leaderboard score submitted: $result');
    } catch (error, stackTrace) {
      debugPrint('Submit leaderboard score error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> showLeaderboard() async {
    if (!_hasLeaderboardId) {
      _logMissingIosLeaderboardId();
      return;
    }

    try {
      final bool isSignedIn = await ensureSignedIn();

      if (!isSignedIn) {
        debugPrint('Leaderboard not shown: player is not signed in.');
        return;
      }

      await Leaderboards.showLeaderboards(
        androidLeaderboardID: defaultTargetPlatform == TargetPlatform.android
            ? leaderboardId
            : '',
        iOSLeaderboardID: defaultTargetPlatform == TargetPlatform.iOS
            ? iosLeaderboardId
            : '',
      );
    } catch (error, stackTrace) {
      debugPrint('Show leaderboard error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<Object?> loadTopScores({int maxResults = 20}) async {
    if (!_hasLeaderboardId) {
      _logMissingIosLeaderboardId();
      return null;
    }

    try {
      final bool isSignedIn = await ensureSignedIn();

      if (!isSignedIn) {
        return null;
      }

      final scores = await Leaderboards.loadLeaderboardScores(
        androidLeaderboardID: defaultTargetPlatform == TargetPlatform.android
            ? leaderboardId
            : '',
        iOSLeaderboardID: defaultTargetPlatform == TargetPlatform.iOS
            ? iosLeaderboardId
            : '',
        scope: PlayerScope.global,
        timeScope: TimeScope.allTime,
        maxResults: maxResults,
      );

      debugPrint('Leaderboard scores: $scores');

      return scores;
    } catch (error, stackTrace) {
      debugPrint('Load leaderboard scores error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  void _logMissingIosLeaderboardId() {
    if (defaultTargetPlatform == TargetPlatform.iOS &&
        iosLeaderboardId.isEmpty) {
      debugPrint('Game Center leaderboard is not configured.');
    }
  }
}
