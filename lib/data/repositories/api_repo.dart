import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:magic_games/data/api/api_end_points.dart';
import 'package:magic_games/data/api/dio_client.dart';
import 'package:magic_games/data/model/game_model.dart';

class ApiRepo {
  ApiRepo(this.dioClient);

  final DioClient dioClient;

  Future<GameModel> getGames() async {
    try {
      final Response<dynamic> response = await dioClient.get(
        Endpoints.getGames,
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
