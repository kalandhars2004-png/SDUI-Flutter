# Roadmap

## Completed (v0.1.0)
- Core model UiNode/UiDocument with immutable updates & history
- Parser / Serializer / Validator
- ComponentRegistry + ActionRegistry (no switch)
- Built-ins: text, button, column, row, container, padding, center, stack, image, card, icon, divider, list, sizedbox
- RenderContext + SduiTheme
- Unknown fallback + error handling
- SduiEngine + SduiView
- Builder: 3-zone layout, palette (draggable), canvas (nested, selectable), inspector (generic), Generate/Load JSON
- Playground with tabs (Builder / Preview / Demo), custom injection demos
- Tests for round-trip, registry, validation, nesting

## Next
- Undo/redo UI polish + keyboard shortcuts (Ctrl+Z)
- Reorder via ReorderableListView + explicit parent drop zones
- Style: spacing system, elevation, gradients
- More components: AppBar, Grid, Form (TextField + validation), BottomNav, TabView
- State binding: `{{data.key}}` templating + dataProvider resolver
- Expressions: `visible: "{{user.isPremium}}"` conditional rendering
- Asset resolver for local images + caching
- JSON Schema editor with CodeMirror / syntax highlight
- Export/import history to file (FilePicker save)
- Golden tests for renderer
- Web: shareable URL with encoded JSON
- Performance: const constructors, RepaintBoundary per node

## Future (v1.0)
- Server SDK (Node/Dart) to emit JSON from backend models
- Visual action editor (chain actions, conditionals)
- Multi-document pages + navigation graph
- Figma plugin → SDUI JSON
- CLI to validate/lint JSON files
