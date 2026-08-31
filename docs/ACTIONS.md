# Actions

Actions decouple gesture handling from rendering.

## Architecture
```
JSON "events": {"onTap": {"action":"show_dialog","title":"Hi"}}
   ↓
RenderContext.dispatchAction(eventConfig)
   ↓
ActionRegistry.resolve(actionType)
   ↓
ActionHandler.handle(context, params)
```

## Interface
`packages/sdui_engine/lib/actions/action_handler.dart:3`
```dart
abstract class ActionHandler {
  Future<void> handle(RenderContext context, Map<String,dynamic> params);
}
```

## Built-ins
- `ShowDialogAction` — `{"action":"show_dialog","title":"...","message":"..."}` → `AlertDialog`
- `ShowSnackbarAction` — `{"action":"show_snackbar","message":"..."}` → `SnackBar`
- `NavigateAction` — `{"action":"navigate","route":"/detail"}` → `Navigator.pushNamed`
- `CallbackAction` — `{"action":"callback","name":"my_event"}` → `RenderContext.onAction?.call(name, params)`

Registered in `SduiEngine` ctor (`packages/sdui_engine/lib/sdui.dart:40`) if registry empty.

## Host Custom Action
```dart
class OpenPaymentAction implements ActionHandler {
  @override Future<void> handle(RenderContext c, Map<String,dynamic> p) async {
    final amount = p['amount'];
    ScaffoldMessenger.of(c.context).showSnackBar(SnackBar(content: Text('Pay \$$amount')));
  }
}
engine.registerAction("open_payment", OpenPaymentAction());
```
JSON:
```json
{"type":"button","props":{"text":"Pay"},"events":{"onTap":{"action":"open_payment","amount":"199"}}}
```
Or via `SduiView(onAction: (type, params) => ...)` for `callback`/`open_url` aliases.

## Events Keys
Component renderers check `node.events["onTap"]`/`["onPressed"]`/`["onClick"]`. Value can be a map (full action) or a string shorthand (`"show_snackbar"`).

## Error Handling
Unknown `action` logs via `debugPrint` and no-ops — never crashes render.
