import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_engine/appzillon/appzillon_plugin.dart';

void main() {
  test('pasted singleChildScrollView JSON parses flexibly', () {
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
    final engine = SduiEngine();
    engine.registerPlugin(AppzillonPlugin());
    final doc = engine.parseJsonString(jsonString);
    expect(doc.root.type.toLowerCase(), 'singlechildscrollview');
    expect(doc.root.children.length, 1);
    final padding = doc.root.children.first;
    expect(padding.type, 'padding');
    expect(padding.props['padding'], 24);
    final col = padding.children.first;
    expect(col.type, 'column');
    expect(col.children.length, 5);
    // first text should have props value flattened
    final firstText = col.children.first;
    expect(firstText.type, 'text');
    expect(firstText.props['value'], 'Welcome to SDUI');
    expect(firstText.style['fontSize'], 30);
    // ensure sizedBox height flattened
    final sb = col.children[1];
    expect(sb.type.toLowerCase(), 'sizedbox');
    expect(sb.props['height'], 10);
    // ensure registry resolves aliases case-insensitively
    expect(engine.componentRegistry.contains('singleChildScrollView'), isTrue);
    expect(engine.componentRegistry.contains('SIZEDBOX'), isTrue);
    expect(engine.componentRegistry.contains('elevatedButton'), isTrue);
    expect(engine.componentRegistry.contains('listTile'), isTrue);
  });

  test('child vs children flex', () {
    final engine = SduiEngine();
    const json = {
      'type': 'padding',
      'padding': 20,
      'child': {'type': 'text', 'props': {'text': 'Hi'}}
    };
    final doc = engine.parse(json);
    expect(doc.root.children.length, 1);
    expect(doc.root.children.first.props['text'], 'Hi');
  });
}
