import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:magic_games/data/api/dio_client.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/helpers/services/remote_config.dart';

class ApiRepo {
  ApiRepo(this.dioClient, this._remoteConfigService);

  final DioClient dioClient;
  final RemoteConfigService _remoteConfigService;

  Future<GameModel> getGames() async {
    try {
      final Locale locale = WidgetsBinding.instance.platformDispatcher.locale;
      final String languageCode = locale.toLanguageTag().isEmpty
          ? locale.languageCode
          : locale.toLanguageTag();
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
