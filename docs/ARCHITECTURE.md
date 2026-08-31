# Architecture

## Vision
Generic, reusable Server-Driven UI (SDUI) framework for Flutter. The playground is a demo; the real product is `sdui_engine`.

```
                  ┌─────────────────────┐
                  │   Visual Builder UI │
                  │      / Playground   │
                  └──────────┬──────────┘
                             │
                             ▼
                      Generic UI JSON
                             │
                             ▼
                  ┌─────────────────────┐
                  │     SDUI Engine     │
                  │  Parser             │
                  │  UI Model           │
                  │  Registry           │
                  │  Renderer           │
                  │  Property Resolver  │
                  │  Action Resolver    │
                  └──────────┬──────────┘
                             │
                             ▼
                    Native Flutter Widgets
```

## Layer Separation
- **sdui_engine** must NOT import builder screens, drag-drop, property inspector.
- **sdui_builder** depends on `sdui_engine`.
- **playground** depends on both.

```
sdui_builder
      ↓
sdui_engine
```

## Single Source of Truth
```
              UiNode Tree (UiDocument)
             /     |      \
            /      |       \
           ▼       ▼        ▼
       Canvas     JSON     Renderer
```
`UiDocument` + `UiNode` is the canonical model. Builder edits it, serializer emits JSON, parser restores it, renderer renders it. The widget tree is derived, never the source.

## Core Primitives
- `UiNode` (`packages/sdui_engine/lib/core/ui_node.dart:1`): `type`, `props`, `style`, `events`, `children`, stable `id`.
- `UiDocument` (`packages/sdui_engine/lib/core/ui_document.dart:1`): `version` + `root` node, plus helpers `findById`, `updateNode`, `removeNode`, `insertChild`, `moveNode`.
- `ComponentRegistry` (`packages/sdui_engine/lib/registry/component_registry.dart:1`): `Map<String, ComponentRenderer>`.
- `ActionRegistry` (`packages/sdui_engine/lib/registry/action_registry.dart:1`): `Map<String, ActionHandler>`.
- `SduiRenderer` (`packages/sdui_engine/lib/renderer/sdui_renderer.dart:1`): resolves `node.type → ComponentRenderer` and calls `render`.
- `RenderContext` (`packages/sdui_engine/lib/renderer/render_context.dart:1`): DI container passed to every renderer (context, registries, theme, callbacks, data).
- `SduiEngine` (`packages/sdui_engine/lib/sdui.dart:17`): facade exposing `registerComponent`, `registerAction`, `parse`, `toJson`, `render`, plus `SduiView` widget.

## No Switch Anti-Pattern
```dart
// ❌ forbidden in core renderer
switch (node.type) { case 'text': return Text(...); }

// ✅ registry
registry.register("text", TextRenderer());
registry.resolve(node.type)?.render(node, ctx, childRenderer);
```
Adding a component never touches `SduiRenderer` — only `registry.register`.

## Theme Layer
`SduiTheme` (`packages/sdui_engine/lib/theme/sdui_theme.dart:1`) is injected via `RenderContext`. Same JSON renders differently per host app. Engine never forces a design system.

## Responsibilities
- **Parser** (`packages/sdui_engine/lib/parser/sdui_parser.dart:1`): JSON → UiDocument, delegates to `SduiValidator`.
- **Validator** (`packages/sdui_engine/lib/parser/sdui_validator.dart:1`): structural checks (version, type, props/style/events as maps, children as array). Returns `ValidationResult`.
- **Serializer** (`packages/sdui_engine/lib/parser/sdui_serializer.dart:1`): UiDocument → JSON (wire format omits internal `id` unless requested).
- **PropertyResolver** (`packages/sdui_engine/lib/resolvers/property_resolver.dart:1`): parses `color`, `padding`, `margin`, `alignment`, `fontWeight`, etc. from `props`/`style`.
- **Components** (`packages/sdui_engine/lib/components/`): each implements `ComponentRenderer` (`packages/sdui_engine/lib/renderer/component_renderer.dart:1`). Built-ins registered in `built_in.dart`.

## Error Handling
- `UnknownComponentRenderer` shows `⚠ Unknown component type: xxx` with amber styling, rest of tree continues.
- `ErrorComponentRenderer` handles exceptions inside `SduiRenderer.renderNode`.
- Validator surfaces human-readable errors before render.

## History / Undo Foundation
`BuilderController` keeps `List<UiDocument> _history` and `updateNode`/`insertChild` produce immutable new documents, enabling undo/redo via `_historyIndex` without coupling drag-drop to widget state.
