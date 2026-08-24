import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/view/screens/shop/controller/shop_controller.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShopController>(
      init: ShopController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.themeColor,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, controller),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppResponsive.space(16),
                    ),
                    child: Column(
                      children: [
                        Gap(AppResponsive.space(30)),
                        _buildSectionHeader('Coin Pack'),
                        Gap(AppResponsive.space(24)),
                        Row(
                          children: [
                            Expanded(
                              child: _buildShopItem(
                                icon: Assets.png.shop.icCoin1,
                                amount: '500',
                                price: _getPrice(
                                  controller,
                                  ShopController.coinPack1,
                                  '\$ 0.99',
                                ),
                                onTap: () => controller.buyCoins(500),
                              ),
                            ),
                            Gap(AppResponsive.space(16)),
                            Expanded(
                              child: _buildShopItem(
                                icon: Assets.png.shop.icCoin2,
                                amount: '4000',
                                price: _getPrice(
                                  controller,
                                  ShopController.coinPack2,
                                  '\$ 4.99',
                                ),
                                onTap: () => controller.buyCoins(4000),
                              ),
                            ),
                          ],
                        ),
                        Gap(AppResponsive.space(50)),
                        _buildSectionHeader('Diamond Pack'),
                        Gap(AppResponsive.space(24)),
                        Row(
                          children: [
                            Expanded(
                              child: _buildShopItem(
                                icon: Assets.png.shop.icDiamond1,
                                amount: '100',
                                price: _getPrice(
                                  controller,
                                  ShopController.diamondPack1,
                                  '\$ 0.99',
                                ),
                                onTap: () => controller.buyDiamonds(100),
                              ),
                            ),
                            Gap(AppResponsive.space(16)),
                            Expanded(
                              child: _buildShopItem(
                                icon: Assets.png.shop.icDiamond2,
                                amount: '800',
                                price: _getPrice(
                                  controller,
                                  ShopController.diamondPack2,
                                  '\$ 4.99',
                                ),
                                onTap: () => controller.buyDiamonds(800),
                              ),
                            ),
                          ],
                        ),
                        Gap(AppResponsive.space(40)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getPrice(
    ShopController controller,
    String productId,
    String fallback,
  ) {
    final ProductDetails? product = controller.products.firstWhereOrNull(
      (p) => p.id == productId,
    );
    return product?.price ?? fallback;
  }

  Widget _buildHeader(BuildContext context, ShopController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.space(16),
        vertical: AppResponsive.space(12),
      ),
      child: Row(
        children: [
          _buildBalanceItem(
            icon: Assets.png.shop.icCoin,
            value: controller.coins,
          ),
          Gap(AppResponsive.space(12)),
          _buildBalanceItem(
            icon: Assets.png.shop.icDiamond,
            value: controller.diamonds,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1C153F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF7433F9).withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem({
    required AssetGenImage icon,
    required RxInt value,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.only(left: 4, right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C153F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF7433F9).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon.image(width: 28, height: 28, fit: BoxFit.contain),
          const Gap(8),
          Obx(
            () => Text(
              '${value.value}',
              style: poppinsW700.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF2C175B), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '✦ ',
                style: TextStyle(color: AppColors.colorED2EAA, fontSize: 16),
              ),
              Text(
                title.tr,
                style: poppinsW700.copyWith(
                  fontSize: 18,
                  color: AppColors.colorED2EAA,
                ),
              ),
              const Text(
                ' ✦',
                style: TextStyle(color: AppColors.colorED2EAA, fontSize: 16),
              ),
            ],
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFF2C175B), thickness: 1)),
      ],
    );
  }

  Widget _buildShopItem({
    required AssetGenImage icon,
    required String amount,
    required String price,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0630),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF23104E), width: 1.5),
      ),
      child: Column(
        children: [
          icon.image(width: 100, height: 100, fit: BoxFit.contain),
          const Gap(20),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 5),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF140B3B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(amount, style: poppinsW700.copyWith(fontSize: 15)),
          ),
          const Gap(15),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF5820CB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(price, style: poppinsW700.copyWith(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
