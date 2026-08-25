import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/game_detail/controller/game_detail_controller.dart';

class ShopController extends GetxController {
  final SharedPreferenceHelper _sharedPreferenceHelper = Get.find<SharedPreferenceHelper>();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final RxInt coins = 0.obs;
  final RxInt diamonds = 0.obs;
  final RxList<ProductDetails> products = <ProductDetails>[].obs;
  final RxBool isLoading = false.obs;

  static const String coinPack1 = 'com.oneup.onegameplus.coinpack1';
  static const String coinPack2 = 'com.oneup.onegameplus.coinpack2';
  static const String diamondPack1 = 'com.oneup.onegameplus.diamondpack1';
  static const String diamondPack2 = 'com.oneup.onegameplus.diamondpack2';

  static const Set<String> _kIds = {
    coinPack1,
    coinPack2,
    diamondPack1,
    diamondPack2,
  };

  @override
  void onInit() {
    super.onInit();
    _loadBalances();
    _initializeIAP();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void _loadBalances() {
    coins.value = _sharedPreferenceHelper.getCoins;
    diamonds.value = _sharedPreferenceHelper.getDiamonds;
  }

  Future<void> _initializeIAP() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      debugPrint('Store not available');
      return;
    }

    _subscription = _inAppPurchase.purchaseStream.listen(
      _listenToPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Purchase error: $error'),
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    isLoading.value = true;
    update();
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_kIds);
      if (response.error == null) {
        products.assignAll(response.productDetails);
      }
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> buyProduct(String productId) async {
    final ProductDetails? product =
        products.firstWhereOrNull((p) => p.id == productId);
    if (product == null) {
      await _showToastMessage('Product not found'.tr);
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI if needed
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('Purchase error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          await _deliverProduct(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    switch (purchaseDetails.productID) {
      case coinPack1:
        await _addCoins(500);
        break;
      case coinPack2:
        await _addCoins(4000);
        break;
      case diamondPack1:
        await _addDiamonds(100);
        break;
      case diamondPack2:
        await _addDiamonds(800);
        break;
    }
  }

  Future<void> _addCoins(int amount) async {
    final int newTotal = coins.value + amount;
    await _sharedPreferenceHelper.saveCoins(value: newTotal);
    coins.value = newTotal;
    if (Get.isRegistered<GameDetailController>()) {
      await Get.find<GameDetailController>().sendBalanceUpdateToJs();
      await Get.find<GameDetailController>().saveCommonData();
    }
    await _showToastMessage('You got $amount coins!'.tr);
  }

  Future<void> _addDiamonds(int amount) async {
    final int newTotal = diamonds.value + amount;
    await _sharedPreferenceHelper.saveDiamonds(value: newTotal);
    diamonds.value = newTotal;
    if (Get.isRegistered<GameDetailController>()) {
      await Get.find<GameDetailController>().sendBalanceUpdateToJs();
      await Get.find<GameDetailController>().saveCommonData();
    }
    await _showToastMessage('You got $amount diamonds!'.tr);
  }

  Future<void> _showToastMessage(final String message) async {
    if (message.isEmpty) {
      return;
    }

    Get.closeAllSnackbars();
    await Future<void>.delayed(const Duration(milliseconds: 100));

    Get.rawSnackbar(
      messageText: Text(
        message,
        style: poppinsW400.copyWith(
          fontSize: AppResponsive.font(15),
          color: AppColors.white,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: AppColors.themeColor,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.only(
        left: AppResponsive.space(20),
        right: AppResponsive.space(20),
        bottom: AppResponsive.space(40),
      ),
      borderRadius: AppResponsive.space(12),
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 400),
      isDismissible: true,
    );
  }
  
  // Legacy methods for UI if needed without products loaded
  Future<void> buyCoins(int amount) async {
     String id = amount == 500 ? coinPack1 : coinPack2;
     await buyProduct(id);
  }

  Future<void> buyDiamonds(int amount) async {
     String id = amount == 100 ? diamondPack1 : diamondPack2;
     await buyProduct(id);
  }
}
