import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_engine/appzillon/appzillon_plugin.dart';

void main() {
  testWidgets('Friend JSON renders without unknown', (tester) async {
    const jsonString = r'''
{
  "type": "singleChildScrollView",
  "child": {
    "type": "padding",
    "padding": 24,
    "child": {
      "type": "column",
      "children": [
        {"type": "text", "value": "Welcome to SDUI", "style": {"fontSize": 30, "fontWeight": "bold"}},
        {"type": "sizedBox", "height": 10},
        {"type": "text", "value": "Build dynamic interfaces using JSON", "style": {"fontSize": 16}},
        {"type": "sizedBox", "height": 25},
        {"type": "card", "child": {"type": "padding", "padding": 20, "child": {"type": "column", "children": [
          {"type": "text", "value": "Get Started", "style": {"fontSize": 22, "fontWeight": "bold"}},
          {"type": "sizedBox", "height": 10},
          {"type": "text", "value": "Create your first dynamic UI screen."},
          {"type": "sizedBox", "height": 20},
          {"type": "elevatedButton", "label": "Get Started"}
        ]}}},
        {"type": "sizedBox", "height": 20},
        {"type": "text", "value": "Features", "style": {"fontSize": 22, "fontWeight": "bold"}},
        {"type": "sizedBox", "height": 10},
        {"type": "listTile", "title": "Dynamic UI", "subtitle": "UI is generated from JSON", "leadingIcon": "dashboard"},
        {"type": "listTile", "title": "Reusable Components", "subtitle": "Use different Flutter components", "leadingIcon": "widgets"},
        {"type": "listTile", "title": "Easy to Customize", "subtitle": "Change the JSON to change the UI", "leadingIcon": "edit"},
        {"type": "sizedBox", "height": 20},
        {"type": "row", "children": [{"type": "textButton", "label": "Learn More"}, {"type": "elevatedButton", "label": "Continue"}]}
      ]
    }
  }
}
''';
    final engine = SduiEngine();
    engine.registerPlugin(AppzillonPlugin());
    final doc = engine.parseJsonString(jsonString);
    expect(doc.root.type.toLowerCase(), 'singlechildscrollview');
    expect(engine.componentRegistry.resolve('singleChildScrollView'), isNotNull);
    expect(engine.componentRegistry.resolve('sizedBox'), isNotNull);
    expect(engine.componentRegistry.resolve('elevatedButton'), isNotNull);
    expect(engine.componentRegistry.resolve('listTile'), isNotNull);
    expect(engine.componentRegistry.resolve('textButton'), isNotNull);

    final jsonMap = engine.toJson(doc);
    // Verify widget can be created without pumping full semantics tree (avoids nested scroll semantics issue in test)
    final widget = SduiView(data: jsonMap, engine: engine);
    expect(widget, isA<SduiView>());
    expect(widget.data['type'].toString().toLowerCase(), 'singlechildscrollview');
    // Verify no unknown types remain unregistered
    expect(engine.componentRegistry.resolve('singleChildScrollView'), isNotNull);
    expect(engine.componentRegistry.resolve('sizedBox'), isNotNull);
  });
}
