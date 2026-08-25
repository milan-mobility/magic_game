import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/styles.dart';

void showToast({
  required String message,
  String? title,
  IconData? icon,
  Duration duration = const Duration(seconds: 2),
}) {
  Get.rawSnackbar(
    messageText: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: AppColors.colorED2EAA, size: 20),
          const Gap(10),
        ],
        Expanded(
          child: Text(
            message.tr,
            style: poppinsW700.copyWith(fontSize: 14, color: Colors.white),
          ),
        ),
      ],
    ),
    titleText: title != null
        ? Text(
      title.tr,
      style: poppinsW700.copyWith(
        fontSize: 16,
        color: AppColors.colorED2EAA,
      ),
    )
        : null,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: const Color(0xFF1C153F),
    borderColor: const Color(0xFF7433F9).withValues(alpha: 0.5),
    borderWidth: 1.5,
    borderRadius: 12,
    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    duration: duration,
    isDismissible: true,
    forwardAnimationCurve: Curves.easeOutBack,
  );
}