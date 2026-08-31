import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sdui_engine/sdui_engine.dart';

import '../models/appzillon_catalog.dart';
import '../models/component_definition.dart';

/// Builder state - UiDocument is single source of truth.
/// Supports history for undo/redo readiness (Command pattern).
class BuilderController extends ChangeNotifier {
  UiDocument _document;
  String? _selectedId;
  final List<UiDocument> _history = [];
  int _historyIndex = -1;
  final SduiEngine engine;

  BuilderController({SduiEngine? engine, UiDocument? initial})
    : engine = engine ?? SduiEngine(),
      _document =
          initial ??
          UiDocument(
            root: UiNode(
              type: 'column',
              style: {'gap': 12, 'padding': 16},
              children: [],
            ),
          ) {
    _pushHistory();
  }

  UiDocument get document => _document;
  UiNode get root => _document.root;
  String? get selectedId => _selectedId;
  UiNode? get selectedNode =>
      _selectedId == null ? null : _document.findById(_selectedId!);

  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;

  int _countNodes(UiNode n) {
    int c = 1;
    for (final child in n.children) c += _countNodes(child);
    return c;
  }

  void _pushHistory() {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    // For big JSON (>80 nodes) limit history to avoid freeze
    final isBig = _countNodes(_document.root) > 80;
    final maxHistory = isBig ? 15 : 50;
    _history.add(_cloneDoc(_document));
    _historyIndex = _history.length - 1;
    if (_history.length > maxHistory) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  UiDocument _cloneDoc(UiDocument doc) {
    // Efficient clone preserving ids — no JSON encode for big trees
    return doc.clone();
  }

  void _setDocument(
    UiDocument doc, {
    bool pushHistory = true,
    bool notify = true,
  }) {
    _document = doc;
    if (pushHistory) _pushHistory();
    if (notify) notifyListeners();
  }

  void select(String? id) {
    _selectedId = id;
    notifyListeners();
  }

  void addNode(ComponentDefinition def, {String? parentId}) {
    final node = def.createNode();
    final pid = parentId ?? _selectedId ?? root.id;
    // check if parent can have children, else use root
    final parent = _document.findById(pid);
    final targetId = _canHaveChildren(parent?.type ?? '') ? pid : root.id;
    _setDocument(_document.insertChild(targetId, node));
    select(node.id);
  }

  void addNodeDirect(UiNode node, {String? parentId}) {
    final pid = parentId ?? _selectedId ?? root.id;
    final parent = _document.findById(pid);
    final targetId = _canHaveChildren(parent?.type ?? '') ? pid : root.id;
    _setDocument(_document.insertChild(targetId, node));
    select(node.id);
  }

  bool _canHaveChildren(String type) {
    final low = type.toLowerCase();
    final az = AppzillonComponentCatalog.byType(type);
    if (az != null) return az.canHaveChildren;
    final def = ComponentCatalog.byType(type);
    if (def != null) return def.canHaveChildren;
    const containers = {
      'column',
      'row',
      'container',
      'card',
      'list',
      'stack',
      'padding',
      'center',
      'singlechildscrollview',
      'singleChildScrollView',
      'listview',
      'gridview',
      'form',
      'wrap',
      'expanded',
      'flexible',
      'appzillon.row',
      'appzillon.column',
      'appzillon.simple_panel',
      'appzillon.tab',
      'appzillon.accordion',
      'appzillon.carousel',
      'appzillon.collapsible',
      'appzillon.panel_section',
      'appzillon.list',
      'appzillon.form',
      'appzillon.table',
      'appzillon.menu',
      'appzillon.check_group',
      'appzillon.sort_code_list',
    };
    return containers.contains(low) || containers.contains(type);
  }

  void deleteSelected() {
    if (_selectedId == null || _selectedId == root.id) return;
    _setDocument(_document.removeNode(_selectedId!));
    _selectedId = null;
  }

  void deleteNode(String id) {
    if (id == root.id) return;
    _setDocument(_document.removeNode(id));
    if (_selectedId == id) _selectedId = null;
  }

  void updateSelectedProps(String group, String key, dynamic value) {
    if (_selectedId == null) return;
    _setDocument(
      _document.updateNode(_selectedId!, (old) {
        final newProps = Map<String, dynamic>.from(old.props);
        final newStyle = Map<String, dynamic>.from(old.style);
        final newEvents = Map<String, dynamic>.from(old.events);
        if (group == 'props') {
          if (value == null || (value is String && value.isEmpty)) {
            newProps.remove(key);
          } else {
            newProps[key] = value;
          }
        } else if (group == 'style') {
          if (value == null || (value is String && value.isEmpty)) {
            newStyle.remove(key);
          } else {
            newStyle[key] = value;
          }
        } else if (group == 'events') {
          if (value == null || (value is String && value.isEmpty)) {
            newEvents.remove(key);
          } else {
            // events value is action config or string
            if (value is String) {
              newEvents[key] = {'action': value};
            } else {
              newEvents[key] = value;
            }
          }
        }
        return old.copyWith(
          props: newProps,
          style: newStyle,
          events: newEvents,
        );
      }),
    );
  }

  void moveNode(String nodeId, String newParentId, int index) {
    _setDocument(_document.moveNode(nodeId, newParentId, index));
  }

  void reorderInParent(String parentId, int oldIndex, int newIndex) {
    final parent = _document.findById(parentId);
    if (parent == null) return;
    final list = List<UiNode>.from(parent.children);
    if (oldIndex < 0 || oldIndex >= list.length) return;
    if (newIndex > list.length) newIndex = list.length;
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    _setDocument(
      _document.updateNode(parentId, (old) => old.copyWith(children: list)),
    );
  }

  void duplicateSelected() {
    if (_selectedId == null) return;
    final node = selectedNode;
    if (node == null) return;
    final clone = _cloneNodeWithNewIds(node);
    // find parent
    final parentId = _findParentId(root, _selectedId!);
    if (parentId == null) return;
    _setDocument(_document.insertChild(parentId, clone));
    select(clone.id);
  }

  UiNode _cloneNodeWithNewIds(UiNode n) {
    return UiNode(
      type: n.type,
      props: Map<String, dynamic>.from(n.props),
      style: Map<String, dynamic>.from(n.style),
      events: Map<String, dynamic>.from(n.events),
      children: n.children.map(_cloneNodeWithNewIds).toList(),
    );
  }

  String? _findParentId(UiNode current, String childId) {
    for (final c in current.children) {
      if (c.id == childId) return current.id;
      final r = _findParentId(c, childId);
      if (r != null) return r;
    }
    return null;
  }

  // JSON pipeline — async with yield to avoid small freeze on large JSON
  String generateJson({bool pretty = true, bool includeIds = false}) {
    if (includeIds)
      return const JsonEncoder.withIndent('  ')
          .convert(_document.toJsonWithIds());
    return engine.toJsonString(_document, pretty: pretty);
  }

  Future<String> generateJsonAsync({
    bool pretty = true,
    bool includeIds = false,
  }) async {
    // yield to let loading UI paint before heavy JSON encode
    await Future.delayed(const Duration(milliseconds: 10));
    return generateJson(pretty: pretty, includeIds: includeIds);
  }

  Map<String, dynamic> generateJsonMap() => engine.toJson(_document);

  void loadFromJson(Map<String, dynamic> json) {
    final doc = engine.parse(json);
    _setDocument(doc);
    _selectedId = null;
  }

  Future<void> loadFromJsonStringAsync(String s) async {
    await Future.delayed(const Duration(milliseconds: 10));
    final doc = engine.parseJsonString(s);
    _setDocument(doc);
    _selectedId = null;
  }

  void loadFromJsonString(String s) {
    final doc = engine.parseJsonString(s);
    _setDocument(doc);
    _selectedId = null;
  }

  void clear() {
    _setDocument(
      UiDocument(
        root: UiNode(
          type: 'column',
          style: {'gap': 12, 'padding': 16},
          children: [],
        ),
      ),
    );
    _selectedId = null;
  }

  void undo() {
    if (!canUndo) return;
    _historyIndex--;
    _document = _cloneDoc(_history[_historyIndex]);
    _selectedId = null;
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _historyIndex++;
    _document = _cloneDoc(_history[_historyIndex]);
    _selectedId = null;
    notifyListeners();
  }
}
