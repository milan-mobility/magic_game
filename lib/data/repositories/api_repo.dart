import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:magic_games/data/api/dio_client.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/helpers/services/remote_config.dart';

class ApiRepo {
  ApiRepo(
    this.dioClient,
    this._remoteConfigService,
    this._sharedPreferenceHelper,
  );

  final DioClient dioClient;
  final RemoteConfigService _remoteConfigService;
  final SharedPreferenceHelper _sharedPreferenceHelper;

  Future<GameModel> getGames() async {
    try {
      final String languageCode = _sharedPreferenceHelper.selectedLanguageCode;
      final Response<dynamic> response = await dioClient.get(
        _remoteConfigService.languagePath(languageCode: languageCode),
      );
      return GameModel.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint(e.toString());
      rethrow;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
