import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:magic_games/helpers/app_responsive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpResponsiveApp(
    WidgetTester tester, {
    required Size size,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    await tester.binding.setSurfaceSize(size);
    addTearDown(() async {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: SizedBox.expand())),
    );
    await tester.pump();
  }

  testWidgets('portrait phone keeps mobile sizing', (
    WidgetTester tester,
  ) async {
    await pumpResponsiveApp(tester, size: const Size(390, 844));

    expect(AppResponsive.isPhone, isTrue);
    expect(AppResponsive.isTablet, isFalse);
    expect(AppResponsive.value(150, tablet: 270), 150);
  });

  testWidgets('landscape phone still keeps mobile sizing', (
    WidgetTester tester,
  ) async {
    await pumpResponsiveApp(tester, size: const Size(844, 390));

    expect(AppResponsive.isPhone, isTrue);
    expect(AppResponsive.isTablet, isFalse);
    expect(AppResponsive.value(150, tablet: 270), 150);
  });

  testWidgets('iPad portrait keeps tablet sizing', (WidgetTester tester) async {
    await pumpResponsiveApp(tester, size: const Size(768, 1024));

    expect(AppResponsive.isTablet, isTrue);
    expect(AppResponsive.isLargeTablet, isFalse);
    expect(AppResponsive.value(150, tablet: 270), 270);
  });

  testWidgets('iPad landscape keeps tablet sizing', (
    WidgetTester tester,
  ) async {
    await pumpResponsiveApp(tester, size: const Size(1024, 768));

    expect(AppResponsive.isTablet, isTrue);
    expect(AppResponsive.isLargeTablet, isFalse);
    expect(AppResponsive.value(150, tablet: 270), 270);
  });
}
