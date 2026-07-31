import 'dart:math' as math;

import 'package:get/get.dart';

class AppResponsive {
  AppResponsive._();

  static const double tabletBreakpoint = 600;

  static const double largeTabletBreakpoint = 900;

  static bool get isTablet => _shortestSide >= tabletBreakpoint;

  static bool get isLargeTablet => _shortestSide >= largeTabletBreakpoint;

  static bool get isPhone => !isTablet;

  static double get _shortestSide {
    final double width = Get.width;
    final double height = Get.height;

    if (width <= 0 || height <= 0) {
      return math.max(width, height);
    }

    return math.min(width, height);
  }

  /// Generic Responsive Value

  static double value(double mobile, {double? tablet, double? largeTablet}) {
    if (isLargeTablet) {
      return largeTablet ?? tablet ?? mobile;
    }

    if (isTablet) {
      return tablet ?? mobile;
    }

    return mobile;
  }

  /// Auto Font Scaling

  static double font(double mobile, {double? tablet, double? largeTablet}) {
    if (tablet != null || largeTablet != null) {
      return value(mobile, tablet: tablet, largeTablet: largeTablet);
    }

    if (isLargeTablet) return mobile + 4;

    if (isTablet) return mobile + 2;

    return mobile;
  }

  /// Auto Spacing

  static double space(double size) {
    if (isLargeTablet) return size + 6;

    if (isTablet) return size + 4;

    return size;
  }

  /// Max Content Width

  static double get contentWidth {
    if (isLargeTablet) return 800;

    if (isTablet) return 600;

    return Get.width;
  }
}
