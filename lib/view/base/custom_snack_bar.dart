import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_colors.dart';
import 'package:magic_games/helpers/app_responsive.dart';
import 'package:magic_games/helpers/styles.dart';
import 'package:magic_games/utils/app_constants.dart';

void showSuccessSnackBar({final String? title, required final String message}) {
  if (message.isNotEmpty) {
    Get.closeAllSnackbars();
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: AppColors.themeColor,
        titleText: Text(
          title ?? AppConstants.appName,
          style: dmSansW600.copyWith(
            fontSize: AppResponsive.font(18),
            color: AppColors.white,
          ),
        ),
        messageText: Text(
          message,
          style: dmSansW400.copyWith(
            fontSize: AppResponsive.font(15),
            color: AppColors.white,
          ),
        ),
        maxWidth: 500,
        duration: const Duration(seconds: 2),
        snackStyle: SnackStyle.FLOATING,
        margin: EdgeInsets.only(
          left: AppResponsive.space(10.0),
          right: AppResponsive.space(10.0),
          bottom: AppResponsive.space(30.0),
        ),
        borderRadius: AppResponsive.space(5),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        snackPosition: SnackPosition.TOP,
      ),
    );
  }
}

void showErrorSnackBar({
  final String? title,
  final int timeInSecond = 2,
  required final String message,
}) {
  if (message.isNotEmpty) {
    Get.closeAllSnackbars();
    Get.showSnackbar(
      GetSnackBar(
        backgroundColor: Colors.red,
        titleText: Text(
          title ?? AppConstants.appName,
          style: dmSansW600.copyWith(
            fontSize: AppResponsive.font(18),
            color: AppColors.white,
          ),
        ),
        messageText: Text(
          message,
          style: dmSansW400.copyWith(
            fontSize: AppResponsive.font(15),
            color: AppColors.white,
          ),
        ),
        maxWidth: 500,
        duration: Duration(seconds: timeInSecond),
        snackStyle: SnackStyle.FLOATING,
        margin: EdgeInsets.only(
          left: AppResponsive.space(10.0),
          right: AppResponsive.space(10.0),
          bottom: AppResponsive.space(30.0),
        ),
        borderRadius: AppResponsive.space(5),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        snackPosition: SnackPosition.TOP,
      ),
    );
  }
}
