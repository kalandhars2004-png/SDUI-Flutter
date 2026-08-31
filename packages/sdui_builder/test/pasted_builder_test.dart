import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_builder/sdui_builder.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_engine/appzillon/appzillon_plugin.dart';

void main() {
  test('Builder loads friend singleChildScrollView JSON', () {
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
        {"type": "elevatedButton", "label": "Get Started"},
        {"type": "listTile", "title": "Dynamic UI", "subtitle": "UI is generated from JSON", "leadingIcon": "dashboard"},
        {"type": "row", "children": [{"type": "textButton", "label": "Learn More"}, {"type": "elevatedButton", "label": "Continue"}]}
      ]
    }
  }
}
''';
    final engine = SduiEngine()..registerPlugin(AppzillonPlugin());
    final ctrl = BuilderController(engine: engine);
    // Should parse without throw
    ctrl.loadFromJsonString(jsonString);
    expect(ctrl.document.root.type.toLowerCase(), 'singlechildscrollview');
    expect(ctrl.document.root.children.length, 1);
    final padding = ctrl.document.root.children.first;
    expect(padding.type, 'padding');
    expect(padding.children.length, 1);
    final col = padding.children.first;
    expect(col.type, 'column');
    expect(col.children.length, greaterThan(3));
    // Generate should round-trip
    final out = ctrl.generateJsonMap();
    expect(out['type'].toString().toLowerCase(), 'singlechildscrollview');
  });
}
