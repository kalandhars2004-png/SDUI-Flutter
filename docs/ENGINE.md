# SDUI Engine

Package: `packages/sdui_engine`

Pure rendering engine — no Builder UI dependency.

## Public API
```dart
final engine = SduiEngine();

engine.registerComponent("product_card", ProductCardRenderer());
engine.registerAction("open_payment", OpenPaymentAction());

// Raw JSON → Widget
Widget w = engine.render(jsonMap, context);

// UiDocument → Widget
Widget w2 = engine.renderDocument(doc, context);

// High-level widget for embedding
SduiView(data: jsonMap, engine: engine, onAction: (t,p) => print(t))
SduiDocumentView(document: doc, engine: engine)
```

## Files
- `lib/sdui.dart` — `SduiEngine`, `SduiView`, `SduiDocumentView`
- `lib/core/ui_node.dart`, `ui_document.dart` — model (source of truth)
- `lib/parser/` — parser, serializer, validator
- `lib/registry/` — `ComponentRegistry`, `ActionRegistry`
- `lib/renderer/` — `ComponentRenderer` interface, `SduiRenderer`, `RenderContext`
- `lib/theme/sdui_theme.dart` — theming
- `lib/resolvers/property_resolver.dart` — style/props helpers
- `lib/components/` — built-ins + `built_in.dart` registrar
- `lib/actions/action_handler.dart` — action handlers

## Lifecycle
1. JSON file → `SduiParser.parse(json)` → `UiDocument`
2. `SduiValidator` checks shape, throws `SduiParseException` on failure
3. `SduiRenderer.renderNode(doc.root, RenderContext(...))` resolves `type` via `ComponentRegistry`
4. Each `ComponentRenderer.render(node, ctx, childRenderer)` builds a native `Widget`, calling `childRenderer` for children recursively.

## Custom Injection
```dart
final engine = SduiEngine();
engine.registerComponent("profile_card", ProfileCardRenderer());
// now any JSON with {"type":"profile_card"} renders it — no engine source change
```

## Isolation Proof
`playground/lib/widgets/custom_components.dart` defines `ProfileCardRenderer` and registers it in `playground/lib/main.dart:28`. Engine core remains untouched.

## SduiView
`lib/sdui.dart:100` is a `StatelessWidget` that parses `data` and delegates to `engine.render`. It temporarily overrides `engine.theme` if a `theme` is supplied, catches exceptions and shows a red error widget instead of crashing.
