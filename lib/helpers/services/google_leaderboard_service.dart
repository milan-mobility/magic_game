import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';

class GoogleLeaderboardService {
  GoogleLeaderboardService._();

  static final GoogleLeaderboardService instance = GoogleLeaderboardService._();

  static const String leaderboardId = 'CgkImLX9nZ8YEAIQAQ';

  Future<bool> signIn() async {
    try {
      await GameAuth.signIn();

      final bool isSignedIn = await GameAuth.isSignedIn;

      debugPrint('Google Play Games signed in: $isSignedIn');

      return isSignedIn;
    } catch (error, stackTrace) {
      debugPrint('Google Play Games sign-in error: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> ensureSignedIn() async {
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
    try {
      final bool isSignedIn = await ensureSignedIn();

      if (!isSignedIn) {
        debugPrint('Score not submitted: player is not signed in.');
        return;
      }

      final result = await Leaderboards.submitScore(
        score: Score(androidLeaderboardID: leaderboardId, value: score),
      );

      debugPrint('Leaderboard score submitted: $result');
    } catch (error, stackTrace) {
      debugPrint('Submit leaderboard score error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> showLeaderboard() async {
    try {
      final bool isSignedIn = await ensureSignedIn();

      if (!isSignedIn) {
        debugPrint('Leaderboard not shown: player is not signed in.');
        return;
      }

      await Leaderboards.showLeaderboards(androidLeaderboardID: leaderboardId);
    } catch (error, stackTrace) {
      debugPrint('Show leaderboard error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<Object?> loadTopScores({int maxResults = 20}) async {
    try {
      final bool isSignedIn = await ensureSignedIn();

      if (!isSignedIn) {
        return null;
      }

      final scores = await Leaderboards.loadLeaderboardScores(
        androidLeaderboardID: leaderboardId,
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
}
