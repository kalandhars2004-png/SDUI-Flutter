import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/sdui_engine.dart';

void main() {
  test('Payment History new screen JSON parses', () {
    const jsonStr = r'''
{
  "screenName": "Payment History",
  "layout": "column",
  "spacing": 18,
  "backgroundColor": "#FFFFFF",
  "components": [
    {"type": "header", "props": {"title": "Payment History", "showBack": true}},
    {"type": "Card", "props": {"style": {"backgroundColor": "#FFFFFF", "borderRadius": 16}}, "children": [
      {"type": "List", "props": {"graphql": {"id": "TransactionList", "query": "query { recentTransactions { id description amount type date } }"}, "children": {"type": "Text", "props": {"text": "{{description}}"}}}}
    ]},
    {"type": "footer", "props": {"items": [{"icon": "home", "label": "Home"}, {"icon": "receipt", "label": "Bills"}]}}
  ]
}
''';
    final engine = SduiEngine();
    final doc = engine.parseJsonString(jsonStr);
    expect(doc.root.type, 'column');
    expect(doc.root.children.length, 3);
    expect(doc.root.children[0].type, 'appzillon.header');
    expect(doc.root.children[1].type, 'card');
    final list = doc.root.children[1].children.first;
    expect(list.type, 'list');
    expect(list.props['graphql'], isA<Map>());
    expect(list.props['childrenTemplate'], isA<Map>());
  });
}
