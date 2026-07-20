import 'dart:async';

import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/view/base/custom_snack_bar.dart';

class VipController extends GetxController {
  VipController(this.sharedPreferenceHelper);

  static const String subscriptionProductId = 'onegame_plus_premium';
  static const String monthlyPlanKey = 'trial3days';
  static const String yearlyPlanKey = 'trial3daysyearly';

  final SharedPreferenceHelper sharedPreferenceHelper;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

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

  bool get canStartPurchase {
    return !hasPremiumAccess &&
        !isPurchasePending &&
        !isLoadingPlans &&
        selectedPlan != null &&
        isStoreAvailable;
  }

  String get purchaseButtonLabel {
    if (hasPremiumAccess) {
      return 'Premium Active';
    }

    if (isPurchasePending) {
      return 'Processing...';
    }

    final VipPlanData? plan = selectedPlan;
    if (plan == null) {
      return 'Plan unavailable';
    }

    if (plan.trialLabel != null) {
      return 'Start ${plan.trialLabel!}';
    }

    return 'Subscribe for ${plan.displayPrice}';
  }

  String get selectedPlanNote {
    return selectedPlan?.noteLabel ??
        'Subscription renews automatically unless canceled.';
  }

  @override
  void onInit() {
    super.onInit();
    hasPremiumAccess = sharedPreferenceHelper.hasPremiumAccess;
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (final Object error) {
        isPurchasePending = false;
        isRestoring = false;
        storeMessage = 'Unable to receive purchase updates.';
        update();
        showErrorSnackBar(message: error.toString());
      },
    );
    loadPlans();
  }

  @override
  void onClose() {
    _purchaseSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadPlans() async {
    isLoadingPlans = true;
    storeMessage = null;
    update();

    try {
      isStoreAvailable = await _inAppPurchase.isAvailable();
      if (!isStoreAvailable) {
        plans = <VipPlanData>[];
        storeMessage = 'The store is not available on this device.';
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
            'No plans were returned for $subscriptionProductId. Check the product setup in the store console.';
        return;
      }

      plans = _buildPlans(response.productDetails);
      if (plans.isEmpty) {
        storeMessage =
            'The product is available, but no purchasable plans could be built from it.';
        return;
      }

      final bool hasSelectedPlan = plans.any(
        (final VipPlanData plan) => plan.planId == selectedPlanId,
      );
      selectedPlanId = hasSelectedPlan ? selectedPlanId : plans.first.planId;
    } catch (error) {
      plans = <VipPlanData>[];
      storeMessage = 'Failed to load subscription plans.';
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
      showErrorSnackBar(message: 'Unable to restore purchases.');
    }
  }

  void selectPlan(final String planId) {
    selectedPlanId = planId;
    update();
  }

  Future<void> startPurchase() async {
    final VipPlanData? plan = selectedPlan;
    if (plan == null || !canStartPurchase) {
      return;
    }

    try {
      isPurchasePending = true;
      update();

      final PurchaseParam purchaseParam = _buildPurchaseParam(plan);
      final bool purchaseStarted = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!purchaseStarted) {
        isPurchasePending = false;
        update();
        showErrorSnackBar(message: 'Unable to start the purchase flow.');
      }
    } catch (error) {
      isPurchasePending = false;
      update();
      showErrorSnackBar(message: 'Unable to start the purchase flow.');
    }
  }

  PurchaseParam _buildPurchaseParam(final VipPlanData plan) {
    if (GetPlatform.isAndroid &&
        plan.productDetails is GooglePlayProductDetails) {
      final GooglePlayProductDetails details =
          plan.productDetails as GooglePlayProductDetails;
      return GooglePlayPurchaseParam(
        productDetails: details,
        offerToken: details.offerToken,
      );
    }

    return PurchaseParam(productDetails: plan.productDetails);
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
          await _grantPremiumAccess(purchaseDetails.productID);
          isPurchasePending = false;
          isRestoring = false;
          showSuccessSnackBar(
            message: purchaseDetails.status == PurchaseStatus.restored
                ? 'Your premium access has been restored.'
                : 'Premium access is now active.',
          );
          break;
        case PurchaseStatus.error:
          isPurchasePending = false;
          isRestoring = false;
          showErrorSnackBar(
            message:
                purchaseDetails.error?.message ??
                'The purchase could not be completed.',
          );
          break;
        case PurchaseStatus.canceled:
          isPurchasePending = false;
          isRestoring = false;
          showErrorSnackBar(
            title: 'Purchase canceled',
            message: 'The subscription purchase was canceled.',
          );
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }

    update();
  }

  Future<void> _grantPremiumAccess(final String productId) async {
    hasPremiumAccess = true;
    await sharedPreferenceHelper.savePremiumAccess(true);
    await sharedPreferenceHelper.savePremiumProductId(productId);
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
            plan.badgeName ?? (index == cheapestIndex ? 'Best Value' : null),
        discountLabel: savingsPercent >= 5 ? 'Save $savingsPercent%' : null,
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
      billedLabel: 'Billed ${fallbackPeriod.toLowerCase()}',
      description: productDetails.description,
      sortOrder: _sortOrderFromLabel(fallbackPeriod),
      normalizedYearlyPrice: productDetails.rawPrice,
      noteLabel:
          'Renews at ${productDetails.price} each ${fallbackPeriod.toLowerCase()}. Cancel anytime.',
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
        ? 'Renews at ${recurringPhase.formattedPrice} per $periodUnit. Cancel anytime.'
        : '$trialLabel, then ${recurringPhase.formattedPrice} per $periodUnit. Cancel anytime.';

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
      billedLabel: 'Billed $periodUnit',
      description: productDetails.description,
      trialLabel: trialLabel,
      sortOrder: cycleDays,
      normalizedYearlyPrice: cycleDays <= 0
          ? productDetails.rawPrice
          : recurringPhase.priceAmountMicros / 1000000 * (365 / cycleDays),
      badgeName: trialLabel != null ? 'Free Trial' : null,
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
      return 'Yearly';
    }
    if (parts.months == 1 &&
        parts.years == 0 &&
        parts.weeks == 0 &&
        parts.days == 0) {
      return 'Monthly';
    }
    if (parts.weeks == 1 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.days == 0) {
      return 'Weekly';
    }
    if (parts.days == 7 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.weeks == 0) {
      return 'Weekly';
    }
    if (parts.days == 1 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.weeks == 0) {
      return 'Daily';
    }
    if (parts.months > 1 &&
        parts.years == 0 &&
        parts.weeks == 0 &&
        parts.days == 0) {
      return '${parts.months} Months';
    }
    if (parts.weeks > 1 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.days == 0) {
      return '${parts.weeks} Weeks';
    }
    if (parts.days > 1 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.weeks == 0) {
      return '${parts.days} Days';
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
      return '${parts.months} months';
    }
    if (parts.weeks > 1 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.days == 0) {
      return '${parts.weeks} weeks';
    }
    if (parts.days > 1 &&
        parts.years == 0 &&
        parts.months == 0 &&
        parts.weeks == 0) {
      return '${parts.days} days';
    }
    return null;
  }

  String _trialLabelFromPeriod(final String billingPeriod) {
    final _IsoPeriodParts parts = _parseBillingPeriod(billingPeriod);
    if (parts.days > 0) {
      return '${parts.days} day free trial';
    }
    if (parts.weeks > 0) {
      return '${parts.weeks * 7} day free trial';
    }
    if (parts.months > 0) {
      return '${parts.months} month free trial';
    }
    if (parts.years > 0) {
      return '${parts.years} year free trial';
    }
    return 'Free trial';
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
