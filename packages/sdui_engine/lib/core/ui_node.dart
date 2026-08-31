import 'dart:convert';

/// Generic UI node - single source of truth for the whole SDUI system.
/// Mirrors: type, props, style, events, children + stable id.
/// Now supports flexible schema: child vs children, flattened props, aliases.
class UiNode {
  final String id;
  final String type;
  final Map<String, dynamic> props;
  final Map<String, dynamic> style;
  final Map<String, dynamic> events;
  final List<UiNode> children;

  UiNode({
    String? id,
    required this.type,
    Map<String, dynamic>? props,
    Map<String, dynamic>? style,
    Map<String, dynamic>? events,
    List<UiNode>? children,
  })  : id = id ?? _generateId(),
        props = props ?? const {},
        style = style ?? const {},
        events = events ?? const {},
        children = children ?? const [];

  static int _counter = 0;
  static String _generateId() => 'n_${DateTime.now().microsecondsSinceEpoch}_${_counter++}';

  UiNode copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? props,
    Map<String, dynamic>? style,
    Map<String, dynamic>? events,
    List<UiNode>? children,
  }) {
    return UiNode(
      id: id ?? this.id,
      type: type ?? this.type,
      props: props ?? Map<String, dynamic>.from(this.props),
      style: style ?? Map<String, dynamic>.from(this.style),
      events: events ?? Map<String, dynamic>.from(this.events),
      children: children ?? List<UiNode>.from(this.children),
    );
  }

  /// Efficient deep clone preserving ids (for history, no JSON encode)
  UiNode clone() => UiNode(
        id: id,
        type: type,
        props: Map<String, dynamic>.from(props),
        style: Map<String, dynamic>.from(style),
        events: Map<String, dynamic>.from(events),
        children: children.map((c) => c.clone()).toList(),
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      if (props.isNotEmpty) 'props': props,
      if (style.isNotEmpty) 'style': style,
      if (events.isNotEmpty) 'events': events,
      if (children.isNotEmpty) 'children': children.map((c) => c.toJson()).toList(),
    };
  }

  Map<String, dynamic> toWireJson() {
    return {
      'type': type,
      if (props.isNotEmpty) 'props': props,
      if (style.isNotEmpty) 'style': style,
      if (events.isNotEmpty) 'events': events,
      if (children.isNotEmpty) 'children': children.map((c) => c.toWireJson()).toList(),
    };
  }

  static const _reserved = {'type', 'props', 'style', 'events', 'children', 'child', 'id', 'version', 'root'};

  factory UiNode.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] as String?;
    if (rawType == null || rawType.isEmpty) {
      throw const FormatException('UiNode missing required field: type');
    }
    final type = rawType; // preserve original for wire, registry resolves case-insensitively

    // children handling: support both "children" array and single "child" object
    List<UiNode> children = [];
    final rawChildren = json['children'];
    final rawChild = json['child'];
    if (rawChildren is List) {
      children = rawChildren.map((e) {
        if (e is Map<String, dynamic>) return UiNode.fromJson(e);
        if (e is Map) return UiNode.fromJson(Map<String, dynamic>.from(e));
        throw FormatException('Invalid child node: $e');
      }).toList();
    } else if (rawChild is Map) {
      // single child -> wrap as one
      final m = rawChild is Map<String, dynamic> ? rawChild : Map<String, dynamic>.from(rawChild as Map);
      children = [UiNode.fromJson(m)];
    } else if (rawChild is List) {
      // rare: child as list
      children = rawChild.map((e) {
        if (e is Map<String, dynamic>) return UiNode.fromJson(e);
        if (e is Map) return UiNode.fromJson(Map<String, dynamic>.from(e));
        throw FormatException('Invalid child node: $e');
      }).toList();
    }

    // props / style / events
    Map<String, dynamic> props = {};
    Map<String, dynamic> style = {};
    Map<String, dynamic> events = {};

    if (json['props'] is Map) props = Map<String, dynamic>.from(json['props'] as Map);
    if (json['style'] is Map) style = Map<String, dynamic>.from(json['style'] as Map);
    if (json['events'] is Map) events = Map<String, dynamic>.from(json['events'] as Map);

    // handle alternative keys: some schemas use "child" style props directly at top-level,
    // or use "value"/"label" instead of "text", "padding" at top-level, etc.
    // Collect any key not in reserved into props (flatten)
    for (final entry in json.entries) {
      final k = entry.key;
      if (_reserved.contains(k)) continue;
      // if already in props/style/events don't duplicate
      if (props.containsKey(k) || style.containsKey(k) || events.containsKey(k)) continue;
      // special: if key is known style-ish (fontSize, color, etc) could go to style? But we keep in props and renderers check both.
      // We put into props as flattened prop.
      props[k] = entry.value;
    }

    // Also if style is empty but props contains style-like keys, keep as props; renderers check both.

    return UiNode(
      id: json['id'] as String?,
      type: type,
      props: props,
      style: style,
      events: events,
      children: children,
    );
  }

  @override
  String toString() => 'UiNode(id:$id, type:$type, children:${children.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UiNode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          _mapEquals(props, other.props) &&
          _mapEquals(style, other.style) &&
          _mapEquals(events, other.events) &&
          _listEquals(children, other.children);

  @override
  int get hashCode => Object.hash(id, type, jsonEncode(props), jsonEncode(style), jsonEncode(events), children.length);

  static bool _mapEquals(Map a, Map b) => jsonEncode(a) == jsonEncode(b);
  static bool _listEquals(List a, List b) => jsonEncode(a.map((e) => e is UiNode ? e.toJson() : e).toList()) == jsonEncode(b.map((e) => e is UiNode ? e.toJson() : e).toList());
}
