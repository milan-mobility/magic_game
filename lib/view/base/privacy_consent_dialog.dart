import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/routes/route_helper.dart';

const String _privacyPolicyUrl =
    'https://oneupapps.oneupitsolution.com/onegameplus/privacy-policy.html';

const String _termsAndConditions =
    'https://oneupapps.oneupitsolution.com/onegameplus/terms-of-use.html';

Future<T?> showPrivacyConsentDialog<T>({required VoidCallback onAccepted}) {
  return Get.dialog<T>(
    PrivacyConsentDialog(onAccepted: onAccepted),
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.72),
  );
}

class PrivacyConsentDialog extends StatelessWidget {
  const PrivacyConsentDialog({super.key, required this.onAccepted});

  final VoidCallback onAccepted;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppResponsive.space(18)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: AppResponsive.value(340, tablet: 420, largeTablet: 460),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppResponsive.space(18),
          vertical: AppResponsive.space(20),
        ),
        decoration: BoxDecoration(
          color: AppColors.color1C153F,
          borderRadius: BorderRadius.circular(AppResponsive.value(16)),
          border: Border.all(
            color: AppColors.color6B35F5.withValues(alpha: 0.9),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.28),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Your Privacy is Important',
              style: poppinsW700.copyWith(
                fontSize: AppResponsive.font(16),
                height: 1.2,
                color: AppColors.white,
              ),
            ),
            Gap(AppResponsive.space(6)),
            Container(
              width: double.infinity,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF2EA4FF),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Gap(AppResponsive.space(16)),
            Container(
              height: 1,
              color: AppColors.color6B35F5.withValues(alpha: 0.28),
            ),
            Gap(AppResponsive.space(22)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppResponsive.space(6)),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  'To Start using this APK, please read and\naccept our Terms of Service\nand Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: poppinsW400.copyWith(
                    fontSize: AppResponsive.font(13.5),
                    height: 1.6,
                    color: AppColors.white.withValues(alpha: 0.92),
                  ),
                ),
              ),
            ),
            Gap(AppResponsive.space(22)),
            Row(
              children: <Widget>[
                Expanded(
                  child: _DialogActionButton(
                    label: 'Privacy Policy',
                    onTap: () => _openDocument(
                      title: 'Privacy Policy',
                      url: _privacyPolicyUrl,
                    ),
                  ),
                ),
                Gap(AppResponsive.space(12)),
                Expanded(
                  child: _DialogActionButton(
                    label: 'Terms & Condition',
                    onTap: () => _openDocument(
                      title: 'Terms of service',
                      url: _termsAndConditions,
                    ),
                  ),
                ),
              ],
            ),
            Gap(AppResponsive.space(20)),
            _AcceptButton(
              onTap: () {
                Get.back<void>();
                onAccepted();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openDocument({required String title, required String url}) {
    Get.toNamed(
      RouteHelper.commonWebView,
      arguments: <String, String>{'title': title, 'url': url},
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppResponsive.value(38, tablet: 44),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppResponsive.value(9)),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.color2A1B59.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(AppResponsive.value(9)),
              border: Border.all(
                color: AppColors.color6B35F5.withValues(alpha: 0.55),
              ),
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: poppinsW500.copyWith(
                  fontSize: AppResponsive.font(12.5),
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AcceptButton extends StatelessWidget {
  const _AcceptButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppResponsive.value(40, tablet: 48),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppResponsive.value(8)),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[Color(0xFF8A2FFF), Color(0xFF6528F7)],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppResponsive.value(8)),
            onTap: onTap,
            child: Center(
              child: Text(
                'Accept & Continue',
                style: poppinsW600.copyWith(
                  fontSize: AppResponsive.font(15),
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
