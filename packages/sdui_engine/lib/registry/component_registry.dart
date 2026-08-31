import '../renderer/component_renderer.dart';

/// Registry pattern: no giant switch(type). Host apps inject custom components.
/// Case-insensitive and alias-aware.
class ComponentRegistry {
  final Map<String, ComponentRenderer> _renderers = {};
  final Map<String, String> _alias = {};

  String _norm(String type) => type.trim().toLowerCase();

  void register(String type, ComponentRenderer renderer) {
    final key = _norm(type);
    _renderers[key] = renderer;
    // also store original for listing
    _renderers[type] = renderer;
  }

  void registerAlias(String alias, String canonical) {
    _alias[_norm(alias)] = _norm(canonical);
  }

  void registerAll(Map<String, ComponentRenderer> map) {
    map.forEach(register);
  }

  void unregister(String type) {
    _renderers.remove(_norm(type));
    _renderers.remove(type);
  }

  bool contains(String type) {
    final n = _norm(type);
    if (_renderers.containsKey(n)) return true;
    if (_renderers.containsKey(type)) return true;
    final aliased = _alias[n];
    if (aliased != null && _renderers.containsKey(aliased)) return true;
    return false;
  }

  ComponentRenderer? resolve(String type) {
    final n = _norm(type);
    // direct
    var r = _renderers[n] ?? _renderers[type];
    if (r != null) return r;
    // alias
    final aliased = _alias[n];
    if (aliased != null) {
      r = _renderers[aliased] ?? _renderers[_alias[aliased] ?? ''];
      if (r != null) return r;
    }
    // fallback: try lowercased without namespace handling?
    // e.g., "sizedBox" -> lowercased "sizedbox" already handled
    return null;
  }

  List<String> get registeredTypes => _renderers.keys.toList()..sort();

  int get length => _renderers.length;

  Map<String, ComponentRenderer> get all => Map.unmodifiable(_renderers);
}
