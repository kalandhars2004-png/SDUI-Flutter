import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playground/main.dart';

void main() {
  testWidgets('Playground loads builder', (WidgetTester tester) async {
    // Ignore network image failures in test environment
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception.toString().contains('NetworkImage') ||
          details.exception.toString().contains('HttpException') ||
          details.exception.toString().contains('HTTP request failed')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(const PlaygroundApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('SDUI Builder'), findsOneWidget);
    expect(find.text('Generate JSON'), findsWidgets);
  });
}
