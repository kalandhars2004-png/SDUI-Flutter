# Registry

Registry is the extensibility seam — no `switch(type)` in core.

## ComponentRegistry
`packages/sdui_engine/lib/registry/component_registry.dart:1`

```dart
final registry = ComponentRegistry();
registry.register("text", TextRenderer());
registry.register("button", ButtonRenderer());

final renderer = registry.resolve(node.type) ?? UnknownComponentRenderer();
Widget w = renderer.render(node, ctx, childRenderer);
```

- `register(type, renderer)` overwrites on conflict (host can override built-ins).
- `registerAll(map)`
- `resolve(type) → ComponentRenderer?`
- `registeredTypes` sorted list for debugging
- Used by `SduiRenderer` (`packages/sdui_engine/lib/renderer/sdui_renderer.dart:9`)

Fallback: `UnknownComponentRenderer` (`packages/sdui_engine/lib/renderer/component_renderer.dart:22`) shows amber `⚠ Unknown component`.

## ActionRegistry
`packages/sdui_engine/lib/registry/action_registry.dart:1`

```dart
registry.register("show_dialog", ShowDialogAction());
await registry.execute(ctx, {"action":"show_dialog","title":"Hi"});
```

Host custom actions:
```dart
engine.registerAction("open_payment", OpenPaymentAction());
```
JSON then: `{"events":{"onTap":{"action":"open_payment","amount":"199"}}}`

Built-ins: `show_dialog`, `show_snackbar`, `navigate`, `callback`, `open_url`, `api` (last two alias to callback; host maps via `RenderContext.onAction`).

## Why Not Switch
- Open/closed principle: core closed for modification, open for extension.
- Testable: mock renderer injection.
- Host isolation: playground can inject `profile_card` without engine rebuild.

## DI via RenderContext
Registries are injected into `RenderContext` once at render root and passed down the tree, never via globals.
