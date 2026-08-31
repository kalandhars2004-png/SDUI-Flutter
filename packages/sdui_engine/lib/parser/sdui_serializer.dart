import 'dart:convert';

import '../core/ui_document.dart';
import '../core/ui_node.dart';

class SduiSerializer {
  const SduiSerializer();

  Map<String, dynamic> toJson(UiDocument doc) => doc.toJson();

  Map<String, dynamic> toJsonWithIds(UiDocument doc) => doc.toJsonWithIds();

  Map<String, dynamic> nodeToJson(UiNode node) => node.toWireJson();

  String toJsonString(UiDocument doc, {bool pretty = true}) {
    final json = toJson(doc);
    if (pretty) return const JsonEncoder.withIndent('  ').convert(json);
    return jsonEncode(json);
  }

  String nodeToJsonString(UiNode node, {bool pretty = true}) {
    final json = node.toWireJson();
    if (pretty) return const JsonEncoder.withIndent('  ').convert(json);
    return jsonEncode(json);
  }
}
