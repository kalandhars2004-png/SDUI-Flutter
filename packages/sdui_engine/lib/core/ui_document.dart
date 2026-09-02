import 'ui_node.dart';

/// Root document wrapping the tree + version.
/// UiDocument is the single source of truth serialized to JSON.
class UiDocument {
  final String version;
  final UiNode root;

  UiDocument({this.version = '1.0', required this.root});

  Map<String, dynamic> toJson() {
    return {'version': version, ...root.toWireJson()};
  }

  Map<String, dynamic> toJsonWithIds() {
    return {'version': version, ...root.toJson()};
  }

  factory UiDocument.fromJson(Map<String, dynamic> json) {
    final version = (json['version'] as String?) ?? '1.0';
    // Handle new Appzillon entire app format: {screenName, layout, backgroundColor, components: []}
    if (json.containsKey('components') && json['components'] is List) {
      final bg = json['backgroundColor'] as String?;
      final spacing = json['spacing'];
      final layout = json['layout'] as String? ?? 'column';
      final comps = json['components'] as List;
      final children = comps.map((e) {
        if (e is Map<String, dynamic>) return _convertNewComponent(e);
        if (e is Map) return _convertNewComponent(Map<String, dynamic>.from(e as Map));
        throw FormatException('Invalid component: $e');
      }).toList();
      final root = UiNode(
        type: layout.toLowerCase(),
        style: {
          if (bg != null) 'backgroundColor': bg,
          if (spacing != null) 'gap': spacing,
          'padding': 0,
        },
        props: {
          'screenName': json['screenName'],
        },
        children: children,
      );
      return UiDocument(version: version, root: root);
    }
    // root is the whole json minus version
    final rootJson = Map<String, dynamic>.from(json)..remove('version');
    // if json has explicit 'root' wrapper handle it
    final Map<String, dynamic> nodeJson;
    if (rootJson.containsKey('root') && rootJson['root'] is Map) {
      nodeJson = Map<String, dynamic>.from(rootJson['root'] as Map);
    } else {
      nodeJson = rootJson;
    }
    return UiDocument(version: version, root: UiNode.fromJson(nodeJson));
  }

  static UiNode _convertNewComponent(Map<String, dynamic> json) {
    String type = (json['type'] as String? ?? 'container').toLowerCase();
    // Normalize type names: Card -> card, List -> list, Text -> text, etc
    final typeMap = {
      'card': 'card',
      'header': 'appzillon.header',
      'footer': 'footer',
      'list': 'list',
      'text': 'text',
      'column': 'column',
      'row': 'row',
      'padding': 'padding',
      'image': 'image',
      'icon': 'icon',
      'sizedbox': 'sizedbox',
      'expanded': 'expanded',
      'spacer': 'spacer',
      'circleavatar': 'circleAvatar',
      'searchbar': 'searchBar',
      'cardnumber': 'card_number',
    };
    if (typeMap.containsKey(type)) type = typeMap[type]!;

    Map<String, dynamic> props = {};
    Map<String, dynamic> style = {};
    Map<String, dynamic> events = {};
    List<UiNode> children = [];

    final rawProps = json['props'];
    if (rawProps is Map) {
      final p = Map<String, dynamic>.from(rawProps as Map);
      // Handle nested style inside props (new format: props.style)
      if (p['style'] is Map) {
        final s = Map<String, dynamic>.from(p['style'] as Map);
        // Map new style keys to engine style
        for (final e in s.entries) {
          String k = e.key;
          dynamic v = e.value;
          // fullWidth -> expand, center handling
          if (k == 'fullWidth' && v == true) {
            // mark for wrapping
          } else if (k == 'backgroundColor') style['backgroundColor'] = v;
          else if (k == 'borderRadius') style['borderRadius'] = v;
          else if (k == 'padding') style['padding'] = v;
          else if (k == 'margin') style['margin'] = v;
          else if (k == 'elevation') style['elevation'] = v;
          else if (k == 'borderColor') style['borderColor'] = v;
          else style[k] = v;
        }
        p.remove('style');
      }
      // Handle graphql -> keep in props for List renderer
      if (p['graphql'] != null) props['graphql'] = p['graphql'];
      // Handle onTap/loadScreen
      if (p['onTap'] != null) events['onTap'] = {'action': p['onTap'], 'payload': p['payload']};
      if (p['onClick'] != null) events['onTap'] = {'action': p['onClick'], 'payload': p['payload']};
      if (p['onPressed'] != null) events['onTap'] = p['onPressed'];
      // Handle children template for List
      if (p['children'] != null && p['children'] is Map) {
        final tmpl = Map<String, dynamic>.from(p['children'] as Map);
        // Keep template for List renderer to use
        props['childrenTemplate'] = tmpl;
        p.remove('children');
      }
      // Remaining props
      for (final e in p.entries) {
        String k = e.key;
        dynamic v = e.value;
        // Map Text props: size -> fontSize, weight -> fontWeight, color -> color, fontFamily stays
        if (type == 'text' || type == 'appzillon.text') {
          if (k == 'size') style['fontSize'] = v;
          else if (k == 'weight') style['fontWeight'] = v;
          else if (k == 'color') style['color'] = v;
          else if (k == 'fontFamily') style['fontFamily'] = v;
          else props[k] = v;
        } else if (type == 'icon') {
          if (k == 'name') props['icon'] = v;
          else props[k] = v;
        } else {
          props[k] = v;
        }
      }
    }

    // Handle top-level style (new format also has style at top if needed)
    if (json['style'] is Map) {
      style.addAll(Map<String, dynamic>.from(json['style'] as Map));
    }

    // Handle children array (new format)
    final rawChildren = json['children'];
    if (rawChildren is List) {
      children = rawChildren.map((e) {
        if (e is Map<String, dynamic>) return _convertNewComponent(e);
        if (e is Map) return _convertNewComponent(Map<String, dynamic>.from(e as Map));
        throw FormatException('Invalid child: $e');
      }).toList();
    }
    // Legacy child single
    final rawChild = json['child'];
    if (rawChild is Map) {
      final m = rawChild is Map<String, dynamic> ? rawChild : Map<String, dynamic>.from(rawChild as Map);
      children.add(_convertNewComponent(m));
    }

    // Handle footer items -> convert to children
    if (props['items'] is List && (type == 'footer' || type == 'appzillon.footer')) {
      final items = props['items'] as List;
      // Keep items in props for footer renderer
    }

    return UiNode(type: type, props: props, style: style, events: events, children: children);
  }

  UiDocument copyWith({String? version, UiNode? root}) {
    return UiDocument(version: version ?? this.version, root: root ?? this.root);
  }

  UiDocument clone() => UiDocument(version: version, root: root.clone());

  /// Find node by id recursively.
  UiNode? findById(String id) => _find(root, id);

  UiNode? _find(UiNode node, String id) {
    if (node.id == id) return node;
    for (final c in node.children) {
      final r = _find(c, id);
      if (r != null) return r;
    }
    return null;
  }

  /// Immutable update: replace node with id == targetId using updater.
  UiDocument updateNode(String targetId, UiNode Function(UiNode old) updater) {
    UiNode replace(UiNode n) {
      if (n.id == targetId) return updater(n);
      return n.copyWith(children: n.children.map(replace).toList());
    }

    return copyWith(root: replace(root));
  }

  /// Remove node by id (cannot remove root).
  UiDocument removeNode(String targetId) {
    if (root.id == targetId) return this;
    UiNode remove(UiNode n) {
      return n.copyWith(
        children: n.children
            .where((c) => c.id != targetId)
            .map(remove)
            .toList(),
      );
    }

    return copyWith(root: remove(root));
  }

  /// Insert child at index under parentId.
  UiDocument insertChild(String parentId, UiNode child, [int? index]) {
    return updateNode(parentId, (parent) {
      final list = List<UiNode>.from(parent.children);
      if (index == null || index < 0 || index > list.length) {
        list.add(child);
      } else {
        list.insert(index, child);
      }
      return parent.copyWith(children: list);
    });
  }

  /// Move node (reorder or reparent) - command-ready.
  UiDocument moveNode(String nodeId, String newParentId, int newIndex) {
    final node = findById(nodeId);
    if (node == null) return this;
    // first remove
    var doc = removeNode(nodeId);
    // then insert under new parent
    doc = doc.insertChild(newParentId, node, newIndex);
    return doc;
  }
}
