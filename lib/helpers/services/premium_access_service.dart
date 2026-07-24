import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';

class PremiumAccessService extends GetxService {
  PremiumAccessService(this._sharedPreferenceHelper);

  static const String subscriptionProductId = 'onegame_plus_premium';

  final SharedPreferenceHelper _sharedPreferenceHelper;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  bool get hasPremiumAccess => _sharedPreferenceHelper.hasPremiumAccess;

  String? get premiumProductId => _sharedPreferenceHelper.premiumProductId;

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

      final bool hasActivePurchase = response.pastPurchases.any(
        _isOwnedPremiumPurchase,
      );

      if (hasActivePurchase) {
        await grantPremiumAccess(productId: subscriptionProductId);
        return;
      }

      await revokePremiumAccess();
    } catch (_) {
      // Keep the cached premium state if the store query fails.
    }
  }

  Future<void> grantPremiumAccess({String? productId}) async {
    await _sharedPreferenceHelper.savePremiumAccess(true);
    await _sharedPreferenceHelper.savePremiumProductId(
      productId ?? subscriptionProductId,
    );
  }

  Future<void> revokePremiumAccess() async {
    await _sharedPreferenceHelper.savePremiumAccess(false);
    await _sharedPreferenceHelper.savePremiumProductId(null);
  }

  bool _isOwnedPremiumPurchase(final GooglePlayPurchaseDetails purchase) {
    return purchase.productID == subscriptionProductId &&
        purchase.billingClientPurchase.purchaseState ==
            PurchaseStateWrapper.purchased;
  }
}
