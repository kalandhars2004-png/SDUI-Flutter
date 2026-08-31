import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_builder/sdui_builder.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_engine/appzillon/appzillon_plugin.dart';

void main() {
  test('Full friend JSON exact', () {
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
    final engine = SduiEngine()..registerPlugin(AppzillonPlugin());
    final ctrl = BuilderController(engine: engine);
    ctrl.loadFromJsonString(jsonString);
    expect(ctrl.document.root.type.toLowerCase(), 'singlechildscrollview');
    // Should have parsed all nested children
    final col = ctrl.document.root.children.first.children.first;
    expect(col.type, 'column');
    expect(col.children.length, 13);
    // Check that card's child padding was correctly converted from child -> children
    final card = col.children[4];
    expect(card.type, 'card');
    expect(card.children.length, 1);
    expect(card.children.first.type, 'padding');
    // Check text value flattened
    expect(col.children.first.props['value'], 'Welcome to SDUI');
  });
}
