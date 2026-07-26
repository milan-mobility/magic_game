import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/helpers/services/premium_access_service.dart';
import 'package:magic_games/view/base/custom_snack_bar.dart';

class VipController extends GetxController with WidgetsBindingObserver {
  VipController(this.sharedPreferenceHelper);

  static const String subscriptionProductId = 'onegame_plus_premium';
  static const String monthlyPlanKey = 'trial3days';
  static const String yearlyPlanKey = 'trial3daysyearly';

  final SharedPreferenceHelper sharedPreferenceHelper;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final PremiumAccessService _premiumAccessService =
      Get.find<PremiumAccessService>();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool isStoreAvailable = false;
  bool isLoadingPlans = true;
  bool isPurchasePending = false;
  bool isRestoring = false;
  bool hasPremiumAccess = false;
  String? storeMessage;
  String? selectedPlanId;
  List<VipPlanData> plans = <VipPlanData>[];

  VipPlanData? get selectedPlan {
    if (plans.isEmpty) {
      return null;
    }

    for (final VipPlanData plan in plans) {
      if (plan.planId == selectedPlanId) {
        return plan;
      }
    }

    return plans.first;
  }

  VipPlanData? get activePlan {
    if (!hasPremiumAccess || plans.isEmpty) {
      return null;
    }

    return _planForStoredKey(_premiumAccessService.premiumPlanKey) ??
        _planForStoredKey(sharedPreferenceHelper.selectedVipPlanKey) ??
        _planById(selectedPlanId);
  }

  bool get canStartPurchase {
    return !hasPremiumAccess &&
        !isPurchasePending &&
        !isLoadingPlans &&
        selectedPlan != null &&
        isStoreAvailable;
  }

  bool get canSelectPlans {
    return !hasPremiumAccess && !isPurchasePending && !isLoadingPlans;
  }

  String get purchaseButtonLabel {
    if (hasPremiumAccess) {
      return 'Premium Active'.tr;
    }

    if (isPurchasePending) {
      return 'Processing...'.tr;
    }

    final VipPlanData? plan = selectedPlan;
    if (plan == null) {
      return 'Plan unavailable'.tr;
    }

    if (plan.trialLabel != null) {
      return 'Start'.trParams(<String, String>{'trial': plan.trialLabel!.tr});
    }

    return 'Subscribe for'.trParams(<String, String>{
      'price': plan.displayPrice,
    });
  }

  String get selectedPlanNote {
    return selectedPlan?.noteLabel ??
        'Subscription renews automatically unless canceled.'.tr;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    hasPremiumAccess = _premiumAccessService.hasPremiumAccess;
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (final Object error) {
        isPurchasePending = false;
        isRestoring = false;
        storeMessage = 'Unable to receive purchase updates.'.tr;
        update();
        showErrorSnackBar(message: error.toString());
      },
    );
    _initialize();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _purchaseSubscription?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_handleAppResumed());
    }
  }

  Future<void> _initialize() async {
    await _syncPremiumAccess();
    await loadPlans();
  }

  Future<void> _syncPremiumAccess() async {
    await _premiumAccessService.refreshPremiumAccess();
    hasPremiumAccess = _premiumAccessService.hasPremiumAccess;
    update();
  }

  Future<void> loadPlans() async {
    isLoadingPlans = true;
    storeMessage = null;
    update();

    try {
      isStoreAvailable = await _inAppPurchase.isAvailable();
      if (!isStoreAvailable) {
        plans = <VipPlanData>[];
        storeMessage = 'The store is not available on this device.'.tr;
        return;
      }

      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(<String>{subscriptionProductId});

      if (response.error != null) {
        plans = <VipPlanData>[];
        storeMessage = response.error!.message;
        return;
      }

      if (response.productDetails.isEmpty) {
        plans = <VipPlanData>[];
        storeMessage =
            'No plans were returned for Check the product setup in the store console.'
                .trParams(<String, String>{'productId': subscriptionProductId});
        return;
      }

      plans = _buildPlans(response.productDetails);
      if (plans.isEmpty) {
        storeMessage =
            'The product is available, but no purchasable plans could be built from it.'
                .tr;
        return;
      }

      final VipPlanData? premiumPlan = _planForStoredKey(
        _premiumAccessService.premiumPlanKey,
      );
      final VipPlanData? savedSelectedPlan = _planForStoredKey(
        sharedPreferenceHelper.selectedVipPlanKey,
      );
      final VipPlanData? currentSelectedPlan = plans.firstWhereOrNull(
        (final VipPlanData plan) => plan.planId == selectedPlanId,
      );

      selectedPlanId =
          premiumPlan?.planId ??
          savedSelectedPlan?.planId ??
          currentSelectedPlan?.planId ??
          plans.first.planId;
    } catch (error) {
      plans = <VipPlanData>[];
      storeMessage = 'Failed to load subscription plans.'.tr;
      showErrorSnackBar(message: error.toString());
    } finally {
      isLoadingPlans = false;
      update();
    }
  }

  Future<void> restorePurchases() async {
    if (!isStoreAvailable || isRestoring) {
      return;
    }

    isRestoring = true;
    update();

    try {
      await _inAppPurchase.restorePurchases();
    } catch (error) {
      isRestoring = false;
      update();
      showErrorSnackBar(message: 'Unable to restore purchases.'.tr);
    }
  }

  void selectPlan(final String planId) {
    if (!canSelectPlans || selectedPlanId == planId) {
      return;
    }

    selectedPlanId = planId;
    unawaited(
      sharedPreferenceHelper.saveSelectedVipPlanKey(
        _selectionKeyForPlan(_planById(planId)),
      ),
    );
    update();
  }

  Future<void> startPurchase() async {
    final VipPlanData? plan = selectedPlan;
    if (plan == null || !canStartPurchase) {
      return;
    }

    try {
      await sharedPreferenceHelper.saveSelectedVipPlanKey(
        _selectionKeyForPlan(plan),
      );
      isPurchasePending = true;
      update();

      final PurchaseParam purchaseParam = _buildPurchaseParam(plan);
      final bool purchaseStarted = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!purchaseStarted) {
        isPurchasePending = false;
        update();
        showErrorSnackBar(message: 'Unable to start the purchase flow.'.tr);
      }
    } catch (error) {
      isPurchasePending = false;
      update();
      showErrorSnackBar(message: 'Unable to start the purchase flow.'.tr);
    }
  }

  Future<void> _handleAppResumed() async {
    await _syncPremiumAccess();

    if (!hasPremiumAccess && (isPurchasePending || isRestoring)) {
      isPurchasePending = false;
      isRestoring = false;
    }

    if (plans.isEmpty || _planById(selectedPlanId) == null) {
      await loadPlans();
      return;
    }

    update();
  }

  PurchaseParam _buildPurchaseParam(final VipPlanData plan) {
    final String? planKey = _selectionKeyForPlan(plan);

    if (GetPlatform.isAndroid &&
        plan.productDetails is GooglePlayProductDetails) {
      final GooglePlayProductDetails details =
          plan.productDetails as GooglePlayProductDetails;
      return GooglePlayPurchaseParam(
        productDetails: details,
        applicationUserName: planKey,
        offerToken: details.offerToken,
      );
    }

    return PurchaseParam(
      productDetails: plan.productDetails,
      applicationUserName: planKey,
    );
  }

  Future<void> _handlePurchaseUpdates(
    final List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.productID != subscriptionProductId) {
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        continue;
      }

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          isPurchasePending = true;
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _grantPremiumAccess(purchaseDetails);
          isPurchasePending = false;
          isRestoring = false;
          showSuccessSnackBar(
            message: purchaseDetails.status == PurchaseStatus.restored
                ? 'Your premium access has been restored.'.tr
                : 'Premium access is now active.'.tr,
          );
          break;
        case PurchaseStatus.error:
          isPurchasePending = false;
          isRestoring = false;
          showErrorSnackBar(
            message:
                purchaseDetails.error?.message ??
                'The purchase could not be completed.'.tr,
          );
          break;
        case PurchaseStatus.canceled:
          isPurchasePending = false;
          isRestoring = false;
          showErrorSnackBar(
            title: 'Purchase canceled'.tr,
            message: 'The subscription purchase was canceled.'.tr,
          );
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }

    update();
  }

  Future<void> _grantPremiumAccess(
    final PurchaseDetails purchaseDetails,
  ) async {
    final String? purchasedPlanKey =
        purchaseDetails is GooglePlayPurchaseDetails
        ? purchaseDetails.billingClientPurchase.obfuscatedAccountId
        : _selectionKeyForPlan(selectedPlan);

    await _premiumAccessService.grantPremiumAccess(
      productId: purchaseDetails.productID,
      planKey: purchasedPlanKey,
    );
    hasPremiumAccess = _premiumAccessService.hasPremiumAccess;

    final VipPlanData? purchasedPlan = _planForStoredKey(purchasedPlanKey);
    if (purchasedPlan != null) {
      selectedPlanId = purchasedPlan.planId;
      await sharedPreferenceHelper.saveSelectedVipPlanKey(purchasedPlanKey);
    }
  }

  VipPlanData? _planById(final String? planId) {
    if (planId == null) {
      return null;
    }

    return plans.firstWhereOrNull(
      (final VipPlanData plan) => plan.planId == planId,
    );
  }

  VipPlanData? _planForStoredKey(final String? planKey) {
    if (planKey == null || planKey.isEmpty) {
      return null;
    }

    return plans.firstWhereOrNull(
      (final VipPlanData plan) => _selectionKeyForPlan(plan) == planKey,
    );
  }

  String? _selectionKeyForPlan(final VipPlanData? plan) {
    if (plan == null) {
      return null;
    }

    return plan.storePlanKey ?? plan.planId;
  }

  List<VipPlanData> _buildPlans(final List<ProductDetails> productDetailsList) {
    final List<VipPlanData> builtPlans =
        productDetailsList.map(_mapProductToPlan).toList()..sort(
          (final VipPlanData first, final VipPlanData second) =>
              first.sortOrder.compareTo(second.sortOrder),
        );

    final List<VipPlanData> sourcePlans = _configuredPlansForPlatform(
      builtPlans,
    );
    final List<VipPlanData> plansToDisplay = sourcePlans.isNotEmpty
        ? sourcePlans
        : builtPlans;

    if (plansToDisplay.length < 2) {
      return plansToDisplay;
    }

    double highestNormalizedPrice = 0;
    for (final VipPlanData plan in plansToDisplay) {
      if (plan.normalizedYearlyPrice > highestNormalizedPrice) {
        highestNormalizedPrice = plan.normalizedYearlyPrice;
      }
    }

    int cheapestIndex = 0;
    double cheapestPrice = plansToDisplay.first.normalizedYearlyPrice;
    for (int index = 1; index < plansToDisplay.length; index++) {
      if (plansToDisplay[index].normalizedYearlyPrice < cheapestPrice) {
        cheapestPrice = plansToDisplay[index].normalizedYearlyPrice;
        cheapestIndex = index;
      }
    }

    return plansToDisplay.asMap().entries.map((
      final MapEntry<int, VipPlanData> entry,
    ) {
      final int index = entry.key;
      final VipPlanData plan = entry.value;
      final int savingsPercent = highestNormalizedPrice > 0
          ? ((1 - (plan.normalizedYearlyPrice / highestNormalizedPrice)) * 100)
                .round()
          : 0;

      return plan.copyWith(
        badgeName:
            plan.badgeName ?? (index == cheapestIndex ? 'Best Value'.tr : null),
        discountLabel: savingsPercent >= 5
            ? 'save_discount'.trParams(<String, String>{
                'discount': '$savingsPercent%',
              })
            : null,
      );
    }).toList();
  }

  List<VipPlanData> _configuredPlansForPlatform(final List<VipPlanData> plans) {
    if (!GetPlatform.isAndroid) {
      return <VipPlanData>[];
    }

    final List<_ConfiguredPlan> configuredPlans = <_ConfiguredPlan>[
      const _ConfiguredPlan(
        key: monthlyPlanKey,
        title: 'Monthly',
        sortOrder: 30,
      ),
      const _ConfiguredPlan(
        key: yearlyPlanKey,
        title: 'Yearly',
        sortOrder: 365,
      ),
    ];

    final List<VipPlanData> matchedPlans = <VipPlanData>[];
    for (final _ConfiguredPlan configuredPlan in configuredPlans) {
      for (final VipPlanData plan in plans) {
        if (plan.storePlanKey == configuredPlan.key) {
          matchedPlans.add(
            plan.copyWith(
              title: configuredPlan.title,
              sortOrder: configuredPlan.sortOrder,
            ),
          );
          break;
        }
      }
    }

    return matchedPlans;
  }

  VipPlanData _mapProductToPlan(final ProductDetails productDetails) {
    if (productDetails is GooglePlayProductDetails) {
      return _buildGooglePlayPlan(productDetails);
    }

    final String fallbackPeriod = _periodLabelFromTitle(productDetails.title);
    return VipPlanData(
      planId: productDetails.id,
      productDetails: productDetails,
      title: fallbackPeriod,
      displayPrice: productDetails.price,
      periodSuffix: '/ ${fallbackPeriod.toLowerCase()}',
      billedLabel: 'billed_unit'.trParams(<String, String>{
        'unit': fallbackPeriod.toLowerCase(),
      }),
      description: productDetails.description,
      sortOrder: _sortOrderFromLabel(fallbackPeriod),
      normalizedYearlyPrice: productDetails.rawPrice,
      noteLabel: 'Renews at each Cancel anytime.'.trParams(<String, String>{
        'price': productDetails.price,
        'period': fallbackPeriod.toLowerCase(),
      }),
    );
  }

  VipPlanData _buildGooglePlayPlan(
    final GooglePlayProductDetails productDetails,
  ) {
    final List<SubscriptionOfferDetailsWrapper>? offers =
        productDetails.productDetails.subscriptionOfferDetails;
    final SubscriptionOfferDetailsWrapper? offerDetails =
        productDetails.subscriptionIndex != null &&
            offers != null &&
            productDetails.subscriptionIndex! < offers.length
        ? offers[productDetails.subscriptionIndex!]
        : null;
    final List<PricingPhaseWrapper> pricingPhases =
        offerDetails?.pricingPhases ?? <PricingPhaseWrapper>[];

    final PricingPhaseWrapper recurringPhase = _selectRecurringPhase(
      pricingPhases,
      productDetails,
    );
    final PricingPhaseWrapper? trialPhase = _selectTrialPhase(pricingPhases);

    final String periodLabel =
        _displayPeriodLabel(recurringPhase.billingPeriod) ??
        _periodLabelFromTitle(productDetails.title);
    final String periodUnit =
        _periodUnitLabel(recurringPhase.billingPeriod) ??
        periodLabel.toLowerCase();
    final int cycleDays = _durationInDays(recurringPhase.billingPeriod);

    final String? trialLabel = trialPhase == null
        ? null
        : _trialLabelFromPeriod(trialPhase.billingPeriod);
    final String noteLabel = trialLabel == null
        ? 'Renews at each Cancel anytime.'.trParams(<String, String>{
            'price': recurringPhase.formattedPrice,
            'period': periodUnit,
          })
        : 'trial_then_price_period'.trParams(<String, String>{
            'trial': trialLabel,
            'price': recurringPhase.formattedPrice,
            'period': periodUnit,
          });

    return VipPlanData(
      planId:
          '${productDetails.id}_${productDetails.subscriptionIndex ?? 'default'}',
      productDetails: productDetails,
      storePlanKey: offerDetails == null
          ? null
          : offerDetails.offerId ?? offerDetails.basePlanId,
      title: periodLabel,
      displayPrice: recurringPhase.formattedPrice,
      periodSuffix: '/ $periodUnit',
      billedLabel: 'billed_unit'.trParams(<String, String>{'unit': periodUnit}),
      description: productDetails.description,
      trialLabel: trialLabel,
      sortOrder: cycleDays,
      normalizedYearlyPrice: cycleDays <= 0
          ? productDetails.rawPrice
          : recurringPhase.priceAmountMicros / 1000000 * (365 / cycleDays),
      badgeName: trialLabel != null ? 'Free Trial'.tr : null,
      noteLabel: noteLabel,
    );
  }

  PricingPhaseWrapper _selectRecurringPhase(
    final List<PricingPhaseWrapper> pricingPhases,
    final GooglePlayProductDetails productDetails,
  ) {
    for (int index = pricingPhases.length - 1; index >= 0; index--) {
      final PricingPhaseWrapper phase = pricingPhases[index];
      if (phase.priceAmountMicros > 0) {
        return phase;
      }
    }

    return pricingPhases.isNotEmpty
        ? pricingPhases.last
        : PricingPhaseWrapper(
            billingCycleCount: 1,
            billingPeriod: 'P1M',
            formattedPrice: productDetails.price,
            priceAmountMicros: (productDetails.rawPrice * 1000000).round(),
            priceCurrencyCode: productDetails.currencyCode,
            recurrenceMode: RecurrenceMode.finiteRecurring,
          );
  }

  PricingPhaseWrapper? _selectTrialPhase(
    final List<PricingPhaseWrapper> pricingPhases,
  ) {
    for (final PricingPhaseWrapper phase in pricingPhases) {
      if (phase.priceAmountMicros == 0) {
        return phase;
      }
    }

    return null;
  }

  String _periodLabelFromTitle(final String title) {
    final String lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('year')) {
      return 'Yearly';
    }
    if (lowerTitle.contains('month')) {
      return 'Monthly';
    }
    if (lowerTitle.contains('week')) {
      return 'Weekly';
    }
    if (lowerTitle.contains('day')) {
      return 'Daily';
    }
    return 'Premium';
  }

  int _sortOrderFromLabel(final String label) {
    switch (label.toLowerCase()) {
      case 'daily':
        return 1;
      case 'weekly':
        return 7;
      case 'monthly':
        return 30;
      case 'yearly':
        return 365;
      default:
        return 999;
    }
  }

  String? _displayPeriodLabel(final String billingPeriod) {
    final _IsoPeriodParts parts = _parseBillingPeriod(billingPeriod);
    if (parts.years == 1 &&
        parts.months == 0 &&
        parts.weeks == 0 &&
        parts.days == 0) {
      return 'Yearly'.tr;
    }
    if (parts.months == 1 &&
        parts.years == 0 &&
        parts.weeks == 0 &&
        parts.days == 0) {
      return 'Monthly'.tr;
    }
    if (parts.weeks == 1 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.days == 0) {
      return 'Weekly'.tr;
    }
    if (parts.days == 7 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.weeks == 0) {
      return 'Weekly'.tr;
    }
    if (parts.days == 1 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.weeks == 0) {
      return 'Daily'.tr;
    }
    if (parts.months > 1 &&
        parts.years == 0 &&
        parts.weeks == 0 &&
        parts.days == 0) {
      return 'count_months'.trParams(<String, String>{
        'count': '${parts.months}',
      });
    }
    if (parts.weeks > 1 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.days == 0) {
      return 'count_weeks'.trParams(<String, String>{
        'count': '${parts.weeks}',
      });
    }
    if (parts.days > 1 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.weeks == 0) {
      return 'count_days'.trParams(<String, String>{'count': '${parts.days}'});
    }
    return null;
  }

  String? _periodUnitLabel(final String billingPeriod) {
    final _IsoPeriodParts parts = _parseBillingPeriod(billingPeriod);
    if (parts.years == 1 &&
        parts.months == 0 &&
        parts.weeks == 0 &&
        parts.days == 0) {
      return 'year';
    }
    if (parts.months == 1 &&
        parts.years == 0 &&
        parts.weeks == 0 &&
        parts.days == 0) {
      return 'month';
    }
    if (parts.weeks == 1 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.days == 0) {
      return 'week';
    }
    if (parts.days == 7 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.weeks == 0) {
      return 'week';
    }
    if (parts.days == 1 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.weeks == 0) {
      return 'day';
    }
    if (parts.months > 1 &&
        parts.years == 0 &&
        parts.weeks == 0 &&
        parts.days == 0) {
      return 'count_months'.trParams(<String, String>{
        'count': '${parts.months}',
      });
    }
    if (parts.weeks > 1 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.days == 0) {
      return 'count_weeks'.trParams(<String, String>{
        'count': '${parts.weeks}',
      });
    }
    if (parts.days > 1 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.weeks == 0) {
      return 'count_days'.trParams(<String, String>{'count': '${parts.days}'});
    }
    return null;
  }

  String _trialLabelFromPeriod(final String billingPeriod) {
    final _IsoPeriodParts parts = _parseBillingPeriod(billingPeriod);
    if (parts.days > 0) {
      return 'count_day_free_trial'.trParams(<String, String>{
        'count': '${parts.days}',
      });
    }
    if (parts.weeks > 0) {
      return 'count_day_free_trial'.trParams(<String, String>{
        'count': '${parts.weeks * 7}',
      });
    }
    if (parts.months > 0) {
      return 'count_month_free_trial'.trParams(<String, String>{
        'count': '${parts.months}',
      });
    }
    if (parts.years > 0) {
      return 'count_year_free_trial'.trParams(<String, String>{
        'count': '${parts.years}',
      });
    }
    return 'Free trial'.tr;
  }

  int _durationInDays(final String billingPeriod) {
    final _IsoPeriodParts parts = _parseBillingPeriod(billingPeriod);
    return parts.years * 365 + parts.months * 30 + parts.weeks * 7 + parts.days;
  }

  _IsoPeriodParts _parseBillingPeriod(final String billingPeriod) {
    final RegExpMatch? match = RegExp(
      r'^P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)W)?(?:(\d+)D)?$',
    ).firstMatch(billingPeriod);

    if (match == null) {
      return const _IsoPeriodParts();
    }

    return _IsoPeriodParts(
      years: int.tryParse(match.group(1) ?? '') ?? 0,
      months: int.tryParse(match.group(2) ?? '') ?? 0,
      weeks: int.tryParse(match.group(3) ?? '') ?? 0,
      days: int.tryParse(match.group(4) ?? '') ?? 0,
    );
  }
}

class VipPlanData {
  const VipPlanData({
    required this.planId,
    required this.productDetails,
    required this.title,
    required this.displayPrice,
    required this.periodSuffix,
    required this.billedLabel,
    required this.sortOrder,
    required this.normalizedYearlyPrice,
    this.storePlanKey,
    this.description,
    this.badgeName,
    this.discountLabel,
    this.trialLabel,
    this.noteLabel,
  });

  final String planId;
  final ProductDetails productDetails;
  final String? storePlanKey;
  final String title;
  final String displayPrice;
  final String periodSuffix;
  final String billedLabel;
  final String? description;
  final String? badgeName;
  final String? discountLabel;
  final String? trialLabel;
  final String? noteLabel;
  final int sortOrder;
  final double normalizedYearlyPrice;

  VipPlanData copyWith({
    String? title,
    int? sortOrder,
    String? badgeName,
    String? discountLabel,
  }) {
    return VipPlanData(
      planId: planId,
      productDetails: productDetails,
      storePlanKey: storePlanKey,
      title: title ?? this.title,
      displayPrice: displayPrice,
      periodSuffix: periodSuffix,
      billedLabel: billedLabel,
      description: description,
      badgeName: badgeName ?? this.badgeName,
      discountLabel: discountLabel ?? this.discountLabel,
      trialLabel: trialLabel,
      noteLabel: noteLabel,
      sortOrder: sortOrder ?? this.sortOrder,
      normalizedYearlyPrice: normalizedYearlyPrice,
    );
  }
}

class _IsoPeriodParts {
  const _IsoPeriodParts({
    this.years = 0,
    this.months = 0,
    this.weeks = 0,
    this.days = 0,
  });

  final int years;
  final int months;
  final int weeks;
  final int days;
}

class _ConfiguredPlan {
  const _ConfiguredPlan({
    required this.key,
    required this.title,
    required this.sortOrder,
  });

  final String key;
  final String title;
  final int sortOrder;
}
