import '../actions/action_handler.dart';
import '../renderer/render_context.dart';

class ActionRegistry {
  final Map<String, ActionHandler> _handlers = {};

  void register(String actionType, ActionHandler handler) {
    _handlers[actionType] = handler;
  }

  void registerAll(Map<String, ActionHandler> map) => _handlers.addAll(map);

  void unregister(String type) => _handlers.remove(type);

  bool contains(String type) => _handlers.containsKey(type);

  ActionHandler? resolve(String type) => _handlers[type];

  List<String> get registeredTypes => _handlers.keys.toList()..sort();

  Future<void> execute(
    RenderContext context,
    Map<String, dynamic> eventConfig,
  ) async {
    final type = eventConfig['action'] ?? eventConfig['type'];
    if (type is! String) return;
    final handler = _handlers[type];
    if (handler == null) {
      debugPrint('[SDUI] No action handler for: $type');
      return;
    }
    await handler.handle(context, eventConfig);
  }

  Future<void> executeByType(
    RenderContext context,
    String actionType, [
    Map<String, dynamic> params = const {},
  ]) async {
    final handler = _handlers[actionType];
    if (handler == null) return;
    await handler.handle(context, {'action': actionType, ...params});
  }
}

// need debugPrint without importing material in this file? Use simple print.
void debugPrint(String m) {
  // ignore: avoid_print
  print(m);
}
