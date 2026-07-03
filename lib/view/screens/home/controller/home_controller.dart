import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/model/game_model.dart';
import 'package:magic_games/data/repositories/api_repo.dart';
import 'package:magic_games/utils/connection.dart';
import 'package:magic_games/utils/message_constant.dart';
import 'package:magic_games/view/base/custom_snack_bar.dart';

class HomeController extends GetxController {
  HomeController(this.apiRepo);

  final ApiRepo apiRepo;

  final Rx<GameModel?> gameModel = Rx<GameModel?>(null);
  final RxBool isLoading = false.obs;

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
    } catch (e) {
      debugPrint('EXCEPTION=>${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
