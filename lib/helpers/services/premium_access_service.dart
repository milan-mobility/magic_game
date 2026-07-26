import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';

class PremiumAccessService extends GetxService {
  PremiumAccessService(this._sharedPreferenceHelper)
    : _hasPremiumAccess = RxBool(_sharedPreferenceHelper.hasPremiumAccess);

  static const String subscriptionProductId = 'onegame_plus_premium';

  final SharedPreferenceHelper _sharedPreferenceHelper;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final RxBool _hasPremiumAccess;

  bool get hasPremiumAccess => _hasPremiumAccess.value;

  RxBool get hasPremiumAccessRx => _hasPremiumAccess;

  String? get premiumProductId => _sharedPreferenceHelper.premiumProductId;

  String? get premiumPlanKey => _sharedPreferenceHelper.premiumPlanKey;

  Future<void> refreshPremiumAccess() async {
    if (!GetPlatform.isAndroid) {
      return;
    }

    try {
      final bool isStoreAvailable = await _inAppPurchase.isAvailable();
      if (!isStoreAvailable) {
        return;
      }

      final InAppPurchaseAndroidPlatformAddition androidAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final QueryPurchaseDetailsResponse response = await androidAddition
          .queryPastPurchases();

      if (response.error != null) {
        return;
      }

      final GooglePlayPurchaseDetails? activePurchase = response.pastPurchases
          .firstWhereOrNull(_isOwnedPremiumPurchase);

      if (activePurchase != null) {
        await grantPremiumAccess(
          productId: subscriptionProductId,
          planKey: activePurchase.billingClientPurchase.obfuscatedAccountId,
        );
        return;
      }

      await revokePremiumAccess();
    } catch (_) {
      // Keep the cached premium state if the store query fails.
    }
  }

  Future<void> grantPremiumAccess({String? productId, String? planKey}) async {
    await _sharedPreferenceHelper.savePremiumAccess(true);
    await _sharedPreferenceHelper.savePremiumProductId(
      productId ?? subscriptionProductId,
    );
    await _sharedPreferenceHelper.savePremiumPlanKey(planKey);
    _hasPremiumAccess.value = true;
  }

  Future<void> revokePremiumAccess() async {
    await _sharedPreferenceHelper.savePremiumAccess(false);
    await _sharedPreferenceHelper.savePremiumProductId(null);
    await _sharedPreferenceHelper.savePremiumPlanKey(null);
    _hasPremiumAccess.value = false;
  }

  bool _isOwnedPremiumPurchase(final GooglePlayPurchaseDetails purchase) {
    return purchase.productID == subscriptionProductId &&
        purchase.billingClientPurchase.purchaseState ==
            PurchaseStateWrapper.purchased;
  }
}
