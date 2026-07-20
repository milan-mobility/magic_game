import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';

Future<T?> showAppUpdateDialog<T>({
  required VoidCallback onUpdate,
  bool barrierDismissible = false,
  String title = 'Update',
  String message =
      'A new Version APP is available.\nPlease Update to continue using APP.',
  String buttonLabel = 'Update',
}) {
  return Get.dialog<T>(
    AppUpdateDialog(
      onUpdate: onUpdate,
      title: title,
      message: message,
      buttonLabel: buttonLabel,
    ),
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withValues(alpha: 0.78),
  );
}

class AppUpdateDialog extends StatelessWidget {
  const AppUpdateDialog({
    super.key,
    required this.onUpdate,
    this.title = 'Update',
    this.message =
        'A new Version APP is available.\nPlease Update to continue using APP.',
    this.buttonLabel = 'Update',
  });

  final VoidCallback onUpdate;
  final String title;
  final String message;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppResponsive.space(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: AppResponsive.value(340, tablet: 420, largeTablet: 460),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppResponsive.space(18),
          vertical: AppResponsive.space(18),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1247),
          borderRadius: BorderRadius.circular(AppResponsive.value(18)),
          border: Border.all(
            color: AppColors.color752DEA.withValues(alpha: 0.95),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.32),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              title,
              textAlign: TextAlign.center,
              style: poppinsW700.copyWith(
                fontSize: AppResponsive.font(30),
                color: AppColors.white,
                height: 1,
              ),
            ),
            Gap(AppResponsive.space(14)),
            Container(
              width: double.infinity,
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.color5820CB.withValues(alpha: 0.34),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Gap(AppResponsive.space(18)),
            const _UpdateIllustration(),
            Gap(AppResponsive.space(18)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppResponsive.space(8)),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: poppinsW400.copyWith(
                  fontSize: AppResponsive.font(15),
                  height: 1.55,
                  color: AppColors.white.withValues(alpha: 0.95),
                ),
              ),
            ),
            Gap(AppResponsive.space(18)),
            _UpdateActionButton(label: buttonLabel, onTap: onUpdate),
            Gap(AppResponsive.space(8)),
          ],
        ),
      ),
    );
  }
}

class _UpdateActionButton extends StatelessWidget {
  const _UpdateActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppResponsive.value(210, tablet: 250),
      height: AppResponsive.value(48, tablet: 54),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppResponsive.value(8)),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[Color(0xFFF6C759), Color(0xFFFDC35A)],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFFF8C44D).withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppResponsive.value(8)),
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: poppinsW700.copyWith(
                  fontSize: AppResponsive.font(18),
                  color: AppColors.color0D0630,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpdateIllustration extends StatelessWidget {
  const _UpdateIllustration();

  @override
  Widget build(BuildContext context) {
    final double width = AppResponsive.value(220, tablet: 250);
    final double height = AppResponsive.value(165, tablet: 185);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: AppResponsive.value(6),
            top: AppResponsive.value(16),
            child: Transform.rotate(
              angle: -0.32,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0xFFCBFF72), Color(0xFF2CCB53)],
                  ).createShader(bounds);
                },
                child: Icon(
                  Icons.refresh_rounded,
                  size: AppResponsive.value(90, tablet: 102),
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          Positioned(
            right: AppResponsive.value(4),
            bottom: AppResponsive.value(8),
            child: Transform.rotate(
              angle: 0.82,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0xFFFFD44D), Color(0xFFFF8A00)],
                  ).createShader(bounds);
                },
                child: Icon(
                  Icons.refresh_rounded,
                  size: AppResponsive.value(94, tablet: 106),
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          Container(
            width: AppResponsive.value(148, tablet: 164),
            height: AppResponsive.value(118, tablet: 132),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppResponsive.value(18)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  Color(0xFF1C63FF),
                  Color(0xFF5C2BEA),
                  Color(0xFFFF4A4A),
                  Color(0xFFFF8C32),
                ],
                stops: <double>[0.0, 0.42, 0.78, 1.0],
              ),
              border: Border.all(
                color: const Color(0xFFE39DFF).withValues(alpha: 0.78),
                width: 2,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFFFF4D7E).withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: CustomPaint(painter: _UpdatePanelGlowPainter()),
          ),
          Positioned(
            child: Transform.rotate(
              angle: -0.45,
              child: SizedBox(
                width: AppResponsive.value(78, tablet: 90),
                height: AppResponsive.value(110, tablet: 122),
                child: const _RocketIllustration(),
              ),
            ),
          ),
          Positioned(
            top: AppResponsive.value(4),
            right: AppResponsive.value(38),
            child: Container(
              width: AppResponsive.value(48, tablet: 56),
              height: AppResponsive.value(48, tablet: 56),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0xFFFF6078), Color(0xFFE61D52)],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFFE61D52).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.download_rounded,
                color: AppColors.white,
                size: AppResponsive.value(28, tablet: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpdatePanelGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    paint.shader = RadialGradient(
      center: const Alignment(-0.3, -0.45),
      radius: 0.85,
      colors: <Color>[
        Colors.white.withValues(alpha: 0.28),
        Colors.white.withValues(alpha: 0.06),
        Colors.transparent,
      ],
      stops: const <double>[0.0, 0.36, 1.0],
    ).createShader(Offset.zero & size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.width * 0.14),
      ),
      paint,
    );

    paint.shader = LinearGradient(
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
      colors: <Color>[
        const Color(0xFFFF7A30).withValues(alpha: 0.74),
        const Color(0xFFF238C3).withValues(alpha: 0.0),
      ],
    ).createShader(Offset.zero & size);
    final Path sweepPath = Path()
      ..moveTo(size.width * 0.08, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.46,
        size.width * 0.92,
        size.height * 0.18,
      )
      ..lineTo(size.width * 0.92, size.height * 0.92)
      ..lineTo(size.width * 0.08, size.height * 0.92)
      ..close();
    canvas.drawPath(sweepPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RocketIllustration extends StatelessWidget {
  const _RocketIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RocketPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _RocketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect bodyRect = Rect.fromLTWH(
      size.width * 0.32,
      size.height * 0.16,
      size.width * 0.34,
      size.height * 0.60,
    );

    final RRect shadowRect = RRect.fromRectAndRadius(
      bodyRect.shift(Offset(size.width * 0.05, size.height * 0.04)),
      Radius.circular(size.width * 0.18),
    );
    canvas.drawRRect(
      shadowRect,
      Paint()..color = const Color(0xFF1A2C88).withValues(alpha: 0.7),
    );

    final Path bodyPath = Path()
      ..moveTo(size.width * 0.50, size.height * 0.08)
      ..quadraticBezierTo(
        size.width * 0.73,
        size.height * 0.23,
        size.width * 0.66,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.58,
        size.height * 0.82,
        size.width * 0.50,
        size.height * 0.88,
      )
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.82,
        size.width * 0.34,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.27,
        size.height * 0.23,
        size.width * 0.50,
        size.height * 0.08,
      )
      ..close();

    final Paint bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFFFDFEFF), Color(0xFFF2E8F6)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(bodyPath, bodyPaint);

    final Paint strokePaint = Paint()
      ..color = const Color(0xFFF0D3F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;
    canvas.drawPath(bodyPath, strokePaint);

    canvas.drawCircle(
      Offset(size.width * 0.50, size.height * 0.40),
      size.width * 0.10,
      Paint()..color = const Color(0xFF22307A),
    );
    canvas.drawCircle(
      Offset(size.width * 0.48, size.height * 0.37),
      size.width * 0.035,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );

    final Paint wingPaint = Paint()..color = const Color(0xFFF7F2FF);

    final Path leftWing = Path()
      ..moveTo(size.width * 0.34, size.height * 0.56)
      ..quadraticBezierTo(
        size.width * 0.08,
        size.height * 0.72,
        size.width * 0.18,
        size.height * 0.88,
      )
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.82,
        size.width * 0.40,
        size.height * 0.68,
      )
      ..close();
    canvas.drawPath(leftWing, wingPaint);

    final Path rightWing = Path()
      ..moveTo(size.width * 0.66, size.height * 0.56)
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 0.72,
        size.width * 0.82,
        size.height * 0.88,
      )
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * 0.82,
        size.width * 0.60,
        size.height * 0.68,
      )
      ..close();
    canvas.drawPath(rightWing, wingPaint);

    final Path tail = Path()
      ..moveTo(size.width * 0.40, size.height * 0.80)
      ..lineTo(size.width * 0.60, size.height * 0.80)
      ..lineTo(size.width * 0.68, size.height * 0.97)
      ..lineTo(size.width * 0.32, size.height * 0.97)
      ..close();
    canvas.drawPath(tail, Paint()..color = const Color(0xFF1A2D88));

    final Path flameOuter = Path()
      ..moveTo(size.width * 0.50, size.height * 1.00)
      ..quadraticBezierTo(
        size.width * 0.70,
        size.height * 0.90,
        size.width * 0.62,
        size.height * 0.73,
      )
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.80,
        size.width * 0.38,
        size.height * 0.73,
      )
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.90,
        size.width * 0.50,
        size.height * 1.00,
      )
      ..close();
    canvas.drawPath(
      flameOuter,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFFFFF066), Color(0xFFFF8800)],
        ).createShader(Offset.zero & size),
    );

    final Path flameInner = Path()
      ..moveTo(size.width * 0.50, size.height * 0.93)
      ..quadraticBezierTo(
        size.width * 0.60,
        size.height * 0.86,
        size.width * 0.56,
        size.height * 0.77,
      )
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.82,
        size.width * 0.44,
        size.height * 0.77,
      )
      ..quadraticBezierTo(
        size.width * 0.40,
        size.height * 0.86,
        size.width * 0.50,
        size.height * 0.93,
      )
      ..close();
    canvas.drawPath(flameInner, Paint()..color = const Color(0xFFFFF9C4));

    final Paint shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Colors.white.withValues(alpha: 0.9),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size);
    final Path shinePath = Path()
      ..moveTo(size.width * 0.47, size.height * 0.16)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.30,
        size.width * 0.38,
        size.height * 0.50,
      )
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.36,
        size.width * 0.52,
        size.height * 0.20,
      )
      ..close();
    canvas.drawPath(shinePath, shinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
