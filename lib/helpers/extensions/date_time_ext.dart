import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:intl/intl.dart';

extension DateTimeExt on DateTime? {
  String formatMMDDYYYY({final String format = 'dd MMM yyyy'}) {
    if (this == null) {
      return '';
    } else {
      return DateFormat(format, Get.locale?.languageCode ?? 'en').format(_getLocalDate()).toString();
    }
  }

  String formatWeekDay() {
    if (this == null) {
      return '';
    } else {
      return DateFormat('EEE dd MMM', Get.locale?.languageCode ?? 'en').format(_getLocalDate()).toString();
    }
  }

  String formatHHmm() {
    if (this == null) {
      return '';
    } else {
      return DateFormat('hh:mm a', Get.locale?.languageCode ?? 'en').format(_getLocalDate()).toString();
    }
  }

  String formatDDMMMYYYY({final String separator = ','}) {
    if (this == null) {
      return '';
    } else {
      return DateFormat(
        'dd MMM$separator yyyy',
        Get.locale?.languageCode ?? 'en',
      ).format(_getLocalDate()).toString();
    }
  }

  String formatYYYYMMDD() {
    if (this == null) {
      return '';
    } else {
      return DateFormat('yyyy-MM-dd').format(_getLocalDate()).toString();
    }
  }

  DateTime _getLocalDate() {
    return this!.toLocal();
  }

  String greeting() {
    final hour = this!.hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning".tr;
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon".tr;
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening".tr;
    } else {
      return "Good Night".tr;
    }
  }
}
