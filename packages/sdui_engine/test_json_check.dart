import 'dart:convert';
void main() {
  const jsonStr = r'''
{
  "screenName": "Payment History",
  "layout": "column",
  "spacing": 18,
  "backgroundColor": "#FFFFFF",
  "components": [
    {"type": "header", "props": {"title": "Payment History", "showBack": true}},
    {"type": "Card", "props": {"style": {"backgroundColor": "#FFFFFF", "borderRadius": 16}}, "children": [
      {"type": "List", "props": {"graphql": {"id": "TransactionList", "url": "{{url}}", "query": "query { recentTransactions { id description amount type date } }"}, "children": {"type": "Card", "props": {"style": {"borderColor": "#0052FF"}, "onTap": "showTransactionDetail", "payload": {"id": "{{id}}"}}, "children": [{"type": "Text", "props": {"text": "{{description}}"}}]}} 
    ]},
    {"type": "footer", "props": {"items": [{"icon": "home", "label": "Home"}, {"icon": "receipt", "label": "Bills"}]}}
  ]
}
''';
  try {
    final decoded = jsonDecode(jsonStr);
    print('ok: $decoded');
  } catch (e) {
    print('fail: $e');
  }
}
