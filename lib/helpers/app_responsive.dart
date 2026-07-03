import 'package:get/get.dart';

class AppResponsive {
  AppResponsive._();

  static const double tabletBreakpoint = 600;

  static const double largeTabletBreakpoint = 900;

  static bool get isTablet => Get.width >= tabletBreakpoint;

  static bool get isLargeTablet => Get.width >= largeTabletBreakpoint;

  static bool get isPhone => !isTablet;

  /// Generic Responsive Value

  static double value(
    double mobile, {
    double? tablet,
    double? largeTablet,
  }) {
    if (isLargeTablet) {
      return largeTablet ?? tablet ?? mobile;
    }

    if (isTablet) {
      return tablet ?? mobile;
    }

    return mobile;
  }

  /// Auto Font Scaling

  static double font(double size) {
    if (isLargeTablet) return size + 4;

    if (isTablet) return size + 2;

    return size;
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
