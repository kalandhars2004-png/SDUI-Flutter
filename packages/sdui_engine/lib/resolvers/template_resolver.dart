class TemplateResolver {
  static final RegExp _pattern = RegExp(r'\{\{\s*([a-zA-Z0-9_\.\[\]]+)\s*\}\}');

  static String resolve(String template, Map<String, dynamic> data) {
    if (!template.contains('{{')) return template;
    return template.replaceAllMapped(_pattern, (match) {
      final key = match.group(1)!.trim();
      // Handle url special case
      if (key == 'url') return data['url']?.toString() ?? template;
      // Simple dot notation
      final parts = key.split('.');
      dynamic current = data;
      for (final part in parts) {
        if (current is Map<String, dynamic>) {
          current = current[part];
        } else {
          return match.group(0)!;
        }
        if (current == null) return '';
      }
      return current?.toString() ?? '';
    });
  }

  static Map<String, dynamic> resolveMap(Map<String, dynamic> map, Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      final v = entry.value;
      if (v is String) {
        result[entry.key] = resolve(v, data);
      } else if (v is Map<String, dynamic>) {
        result[entry.key] = resolveMap(v, data);
      } else if (v is List) {
        result[entry.key] = v.map((e) => e is String ? resolve(e, data) : e is Map<String, dynamic> ? resolveMap(e, data) : e).toList();
      } else {
        result[entry.key] = v;
      }
    }
    return result;
  }

  static Map<String, dynamic> resolveNodeProps(Map<String, dynamic> props, Map<String, dynamic> data) {
    return resolveMap(props, data);
  }
}
