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
