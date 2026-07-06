import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:magic_games/data/api/api_end_points.dart';
import 'package:magic_games/helpers/extensions/date_time_ext.dart';

extension StringExt on String? {
  bool isNotNullAndEmpty() {
    if (this == null) {
      return false;
    }
    return this!.isNotEmpty;
  }

  bool isVideo() {
    if (this == null) return false;
    final String ext = this!.toLowerCase();

    return ext.endsWith('.mov') || ext.isVideoFileName;
  }

  String imageUrl() {
    if (this == null) return '';
    return '${Endpoints.baseUrl}$this';
  }

  String convertddMMMyyyy({String format = 'yyyy-MM-dd HH:mm:ss'}) {
    if (this == null || this!.isEmpty) {
      return '';
    }
    return (DateFormat(
      format,
    ).parse(this!)).formatMMDDYYYY(format: 'MMM dd, yyyy');
  }

  String convertToWeekDayName() {
    if (this == null || this!.isEmpty) {
      return '';
    }
    return (DateFormat('yyyy-MM-dd hh:mm a').parse(this!)).formatWeekDay();
  }

  String fullDateWithWeekDayName() {
    if (this == null || this!.isEmpty) {
      return '';
    }
    return (DateFormat('yyyy-MM-dd HH:mm:ss').parse(this!)).formatWeekDay();
  }

  String convertFormatHHmm({final String format = 'yyyy-MM-dd hh:mm a'}) {
    if (this == null || this!.isEmpty) {
      return '';
    }
    return (DateFormat(format).parse(this!)).formatHHmm();
  }

  DateTime convertDate() {
    if (this == null || this!.isEmpty) {
      return DateTime.now();
    }
    return (DateFormat('yyyy-MM-dd').parse(this!));
  }

  String toLocalTime({
    String inputFormat = "yyyy-MM-dd HH:mm:ss",
    String outputFormat = "hh:mm a",
  }) {
    if (this == null || this!.trim().isEmpty) return "";

    try {
      final inputFormatter = DateFormat(inputFormat);

      // Parse as UTC explicitly
      DateTime utcTime = inputFormatter.parseUtc(this!);

      // Convert to local timezone
      DateTime localTime = utcTime.toLocal();

      return DateFormat(
        outputFormat,
        Get.locale?.languageCode ?? 'en',
      ).format(localTime);
    } catch (e) {
      return this!;
    }
  }

  String toEndTime(
    int durationMinutes, {
    String inputFormat = "yyyy-MM-dd HH:mm:ss",
    String outputFormat = "hh:mm a",
  }) {
    if (this == null || this!.isEmpty) return "";

    try {
      DateTime startUtc = DateFormat(inputFormat).parseUtc(this!);
      DateTime startLocal = startUtc.toLocal();
      DateTime endLocal = startLocal.add(Duration(minutes: durationMinutes));

      return DateFormat(
        outputFormat,
        Get.locale?.languageCode ?? 'en',
      ).format(endLocal);
    } catch (e) {
      return this!;
    }
  }

  String getFileName() {
    if (this == null) {
      return '';
    }
    return this!.split('/').last;
  }

  String toAppointmentTime({
    final String format = 'yyyy-MM-dd hh:mm a',
    final int duration = 0,
  }) {
    if (this == null || this!.isEmpty) {
      return '';
    }
    return (DateFormat(
      format,
    ).parse(this!).add(Duration(minutes: duration))).formatHHmm();
  }

  String toUtcDateTime() {
    try {
      final inputFormat = DateFormat("yyyy-MM-dd hh:mm a");
      final outputFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

      // Parse as IST (local system time)
      DateTime localTime = inputFormat.parse(this!);

      // Convert to UTC
      DateTime utcTime = localTime.toUtc();

      return outputFormat.format(utcTime);
    } catch (e) {
      return this!; // Return original if parsing fails
    }
  }

  DateTime toLocalDateTime() {
    // Parse string as UTC
    final utcTime = DateTime.parse(this!);

    // Convert to local
    return utcTime.toLocal();
  }

  String getInitials() {
    if (this!.trim().isEmpty) return "";

    // Split by spaces and remove any empty items
    List<String> words = this!.trim().split(RegExp(r"\s+"));

    if (words.length == 1) {
      // Only one word → take first letter
      return words[0][0].toUpperCase();
    } else {
      // More than one word → take first two words only
      return (words[0][0] + words[1][0]).toUpperCase();
    }
  }

  DateTime toLocalAppointmentDateTime(String time) {
    final dateTimeString = "$this $time"; // e.g. "2025-12-06 08:37:00"

    // Parse as UTC first
    final utcDateTime = DateFormat(
      "yyyy-MM-dd HH:mm:ss",
    ).parseUtc(dateTimeString);

    // Convert to local timezone
    return utcDateTime.toLocal();
  }

  String toDoctorAvailabilityText() {
    if (this!.isEmpty) return '';

    try {
      // Extract date from string
      final String datePart = this!.replaceAll('Available on ', '').trim();

      final DateTime parsedDate = DateTime.parse(datePart);
      final DateTime now = DateTime.now();

      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);

      final DateTime availabilityDate = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );

      if (availabilityDate == today) {
        return 'Available'.trParams({'value': 'Today'.tr});
      } else if (availabilityDate == tomorrow) {
        return 'Available'.trParams({'value': 'Tomorrow'.tr});
      } else {
        return DateFormat(
          'dd MMM yyyy',
          Get.locale?.languageCode ?? 'en',
        ).format(parsedDate);
      }
    } catch (e) {
      return '';
    }
  }

  String localizeAmPm() {
    if (this == null || this!.isEmpty) return this ?? '';
    if (Get.locale?.languageCode != 'ar') return this!;
    return this!.replaceAll('AM', 'ص').replaceAll('PM', 'م');
  }

  String localizeUrl() {
    if (this == null || this!.isEmpty) return this ?? '';
    if (Get.locale?.languageCode != 'ar') return this!;
    final Uri? uri = Uri.tryParse(this!);
    if (uri == null) return this!;
    return uri.replace(path: '/ar${uri.path}').toString();
  }
}
