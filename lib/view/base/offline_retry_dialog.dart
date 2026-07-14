import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';

Future<T?> showOfflineRetryDialog<T>({
  required Future<bool> Function() onRetry,
}) {
  return Get.dialog<T>(
    OfflineRetryDialog(onRetry: onRetry),
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.72),
  );
}

class OfflineRetryDialog extends StatefulWidget {
  const OfflineRetryDialog({super.key, required this.onRetry});

  final Future<bool> Function() onRetry;

  @override
  State<OfflineRetryDialog> createState() => _OfflineRetryDialogState();
}

class _OfflineRetryDialogState extends State<OfflineRetryDialog> {
  bool _isRetrying = false;

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
          vertical: AppResponsive.space(16),
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
          children: <Widget>[
            Text(
              "You're Offline",
              textAlign: TextAlign.center,
              style: poppinsW700.copyWith(
                fontSize: AppResponsive.font(18),
                color: AppColors.white,
              ),
            ),
            Gap(AppResponsive.space(10)),
            Container(
              width: double.infinity,
              height: 1,
              color: AppColors.color6B35F5.withValues(alpha: 0.28),
            ),
            Gap(AppResponsive.space(16)),
            SizedBox(
              height: AppResponsive.value(150, tablet: 165),
              child: const Center(child: _OfflineSignalIllustration()),
            ),
            Gap(AppResponsive.space(12)),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppResponsive.value(260, tablet: 320),
              ),
              child: Text(
                'To Start the app, Please connect to\nthe internet and try again.',
                textAlign: TextAlign.center,
                style: poppinsW400.copyWith(
                  fontSize: AppResponsive.font(13.5),
                  height: 1.6,
                  color: AppColors.white.withValues(alpha: 0.92),
                ),
              ),
            ),
            Gap(AppResponsive.space(16)),
            _RetryButton(isLoading: _isRetrying, onTap: _handleRetry),
            Gap(AppResponsive.space(10)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRetry() async {
    if (_isRetrying) {
      return;
    }

    setState(() {
      _isRetrying = true;
    });

    final bool shouldClose = await widget.onRetry();

    if (!mounted) {
      return;
    }

    setState(() {
      _isRetrying = false;
    });

    if (shouldClose && (Get.isDialogOpen ?? false)) {
      Get.back<void>();
    }
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppResponsive.value(220, tablet: 260),
      height: AppResponsive.value(44, tablet: 50),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppResponsive.value(6)),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[Color(0xFFF8C44D), Color(0xFFFED25E)],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFFF8C44D).withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppResponsive.value(6)),
            onTap: isLoading ? null : onTap,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: AppResponsive.value(22),
                      width: AppResponsive.value(22),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.color0D0630,
                        ),
                      ),
                    )
                  : Text(
                      'Retry',
                      style: poppinsW700.copyWith(
                        fontSize: AppResponsive.font(16),
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

class _OfflineSignalIllustration extends StatelessWidget {
  const _OfflineSignalIllustration();

  @override
  Widget build(BuildContext context) {
    final double size = AppResponsive.value(150, tablet: 165);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: Size.square(size),
            painter: _OfflineSignalPainter(),
          ),
          Positioned(
            top: AppResponsive.value(6),
            right: AppResponsive.value(12),
            child: Container(
              width: AppResponsive.value(54, tablet: 60),
              height: AppResponsive.value(54, tablet: 60),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Color(0xFFFDE068), Color(0xFFF79A1C)],
                ),
              ),
              child: Center(
                child: Text(
                  '!',
                  style: poppinsW800.copyWith(
                    fontSize: AppResponsive.font(34),
                    height: 1,
                    color: const Color(0xFF0A6D97),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineSignalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width * 0.48, size.height * 0.58);
    final double startAngle = math.pi * 1.06;
    final double sweepAngle = math.pi * 0.72;

    _drawArc(
      canvas,
      center,
      size.width * 0.48,
      startAngle,
      sweepAngle,
      const <Color>[Color(0xFFD2E7FF), Color(0xFF91C6FF)],
      size.width * 0.12,
    );
    _drawArc(
      canvas,
      center,
      size.width * 0.33,
      startAngle,
      sweepAngle,
      const <Color>[Color(0xFFFFD35D), Color(0xFFFF9D00)],
      size.width * 0.09,
    );
    _drawArc(
      canvas,
      center,
      size.width * 0.20,
      startAngle,
      sweepAngle,
      const <Color>[Color(0xFFFF9C5D), Color(0xFFFF6600)],
      size.width * 0.065,
    );

    final Paint dotPaint = Paint()
      ..shader =
          const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFFF2E86), Color(0xFFE5005B)],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.19, size.height * 0.77),
              radius: size.width * 0.11,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.19, size.height * 0.77),
      size.width * 0.11,
      dotPaint,
    );
  }

  void _drawArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    List<Color> colors,
    double strokeWidth,
  ) {
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint paint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: colors,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
