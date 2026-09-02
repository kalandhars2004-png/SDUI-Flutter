import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/sdui_engine.dart';

void main() {
  test('Full Payment History JSON from user', () {
    const jsonStr = r'''
{
  "screenName": "Payment History",
  "layout": "column",
  "spacing": 18,
  "backgroundColor": "#FFFFFF",
  "components": [
    {
      "type": "header",
      "props": {
        "title": "Payment History",
        "titleFontFamily": "Lato",
        "titleWeight": "600",
        "titleSize": 26,
        "titleColor": "#1A1A1A",
        "backgroundColor": "#FFFFFF",
        "showBack": true,
        "onBack": "loadScreen",
        "payload": { "file": "dashboard.json" }
      }
    },
    {
      "type": "Card",
      "props": {
        "style": {
          "backgroundColor": "#FFFFFF",
          "borderRadius": 16,
          "padding": 16,
          "fullWidth": true,
          "margin": 2,
          "elevation": 0
        }
      },
      "children": [
        {
          "type": "List",
          "props": {
            "graphql": {
              "id": "TransactionList",
              "url": "{{url}}",
              "query": "query { recentTransactions { id description amount type date } }"
            },
            "children": {
              "type": "Card",
              "props": {
                "style": {
                  "backgroundColor": "#FFFFFF",
                  "borderRadius": 14,
                  "padding": 14,
                  "margin": 6,
                  "fullWidth": true,
                  "elevation": 0,
                  "borderColor": "#0052FF"
                },
                "onTap": "showTransactionDetail",
                "payload": {
                  "file": "TransactionDetailPage.json",
                  "id": "{{id}}",
                  "description": "{{description}}",
                  "amount": "{{amount}}",
                  "date": "{{date}}",
                  "type": "{{type}}"
                }
              },
              "children": [
                {"type": "Text", "props": {"text": "{{description}}", "size": 18, "weight": "medium", "color": "#000000", "fontFamily":"Lato"}},
                {"type": "Text", "props": {"text": "₹ {{amount}}", "size": 18, "weight": "bold", "color": "#0052FF", "fontFamily":"Lato"}},
                {"type": "Text", "props": {"text": "{{date}}", "size": 16, "color": "#666666", "fontFamily":"Lato"}}
              ]
            }
          }
        }
      ]
    },
    {
      "type": "footer",
      "props": {
        "backgroundColor": "#FFFFFF",
        "activeColor": "#0052FF",
        "items": [
          {"icon": "home", "label": "Home", "onClick": "loadScreen", "payload": { "file": "dashboard.json" }},
          {"icon": "receipt", "label": "Bills", "active": true, "onClick": "loadScreen", "payload": { "file": "payment_history.json" }}
        ]
      }
    }
  ]
}
''';
    final engine = SduiEngine();
    final doc = engine.parseJsonString(jsonStr);
    expect(doc.root.type, 'column');
    expect(doc.root.children.length, 3);
    expect(doc.root.children[0].type, 'appzillon.header');
    // Check List
    final card = doc.root.children[1];
    expect(card.type, 'card');
    final list = card.children.first;
    expect(list.type, 'list');
    expect(list.props['graphql'], isA<Map>());
  });
}
