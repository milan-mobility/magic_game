import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/data/pref_helper/shared_pref_helper.dart';
import 'package:magic_games/gen/assets.gen.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/routes/route_helper.dart';
import 'package:magic_games/view/base/privacy_consent_dialog.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lockPortraitOrientation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _lockPortraitOrientation();
    }
  }

  void _lockPortraitOrientation() {
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.color0D0630,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: double.infinity,
                child: Assets.png.icWelcome.image(
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            const _WelcomeOverlayGradient(),
            SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (final BuildContext context, final constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(
                            horizontal: AppResponsive.space(24),
                          ).copyWith(
                            top: AppResponsive.space(24),
                            bottom: AppResponsive.space(22),
                          ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: AppResponsive.value(360, tablet: 240),
                          ),
                          Assets.png.icHomeHeader.image(
                            width: AppResponsive.value(292, tablet: 500),
                            fit: BoxFit.contain,
                          ),
                          Gap(AppResponsive.space(44)),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: AppResponsive.value(360, tablet: 560),
                            ),
                            child: Text(
                              'Your New Happy Place with\n100+ Games for Pure Playtime\nBliss'
                                  .tr,
                              textAlign: TextAlign.center,
                              style: poppinsW700.copyWith(
                                fontSize: AppResponsive.font(16),
                                height: 1.45,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          Gap(AppResponsive.space(24)),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: AppResponsive.value(330, tablet: 520),
                            ),
                            child: Text(
                              'Plus, new games monthly- tailored variety\nis the spice of play'
                                  .tr,
                              textAlign: TextAlign.center,
                              style: poppinsW400.copyWith(
                                fontSize: AppResponsive.font(14),
                                height: 1.65,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                          Gap(AppResponsive.value(70, tablet: 64)),
                          _WelcomeStartButton(
                            onTap: () {
                              showPrivacyConsentDialog(
                                onAccepted: () {
                                  final sharedPref =
                                      Get.find<SharedPreferenceHelper>();
                                  sharedPref.saveIntroDone(true);
                                  Get.offNamed(RouteHelper.home);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeOverlayGradient extends StatelessWidget {
  const _WelcomeOverlayGradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const <double>[0.0, 0.5, 1.0],
          colors: [
            AppColors.color0D0630.withValues(alpha: 0),
            AppColors.color0D0630,
            AppColors.color0D0630,
          ],
        ),
      ),
    );
  }
}

class _WelcomeStartButton extends StatelessWidget {
  const _WelcomeStartButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: AppResponsive.value(55, tablet: 70),
        decoration: BoxDecoration(
          color: AppColors.color8752FF,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.symmetric(horizontal: AppResponsive.space(24)),
        child: Row(
          children: [
            const _WelcomeSparkIcon(),
            Expanded(
              child: Text(
                "Let's Start".tr,
                textAlign: TextAlign.center,
                style: poppinsW700.copyWith(
                  fontSize: AppResponsive.font(20),
                  color: AppColors.white,
                ),
              ),
            ),
            const _WelcomeSparkIcon(),
          ],
        ),
      ),
    );
  }
}

class _WelcomeSparkIcon extends StatelessWidget {
  const _WelcomeSparkIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      Assets.svg.icStarWhite,
      height: AppResponsive.value(35, tablet: 45),
      width: AppResponsive.value(35, tablet: 45),
    );
  }
}
