import 'dart:convert';

import '../core/ui_document.dart';
import '../core/ui_node.dart';
import 'sdui_validator.dart';

class SduiParseException implements Exception {
  final String message;
  final List<String> errors;
  SduiParseException(this.message, [this.errors = const []]);
  @override
  String toString() =>
      'SduiParseException: $message ${errors.isNotEmpty ? errors.join(", ") : ""}';
}

class SduiParser {
  const SduiParser();

  UiDocument parse(Map<String, dynamic> json) {
    final result = SduiValidator.validate(json);
    if (!result.isValid) {
      throw SduiParseException('Validation failed', result.errors);
    }
    try {
      return UiDocument.fromJson(json);
    } catch (e) {
      throw SduiParseException('Failed to parse UiDocument: $e');
    }
  }

  UiDocument parseJsonString(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        if (decoded is Map) return parse(Map<String, dynamic>.from(decoded));
        throw SduiParseException('Root JSON must be an object');
      }
      return parse(decoded);
    } on FormatException catch (e) {
      throw SduiParseException('Invalid JSON: ${e.message}');
    }
  }

  UiNode parseNode(Map<String, dynamic> json) {
    final result = SduiValidator.validateNode(json, path: 'root');
    if (!result.isValid)
      throw SduiParseException('Validation failed', result.errors);
    return UiNode.fromJson(json);
  }
}
