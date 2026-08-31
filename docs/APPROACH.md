# SDUI Approach — Generic Flutter Server-Driven UI

> `JSON → Parser → UiNode Tree (AST) → ComponentRegistry → ComponentRenderer → Flutter Widget`

## 1. Goal
Build a **generic, reusable SDUI framework** where UI is driven completely by JSON, without changing Flutter screen code when JSON changes. Support common widgets, nesting, styling, interactions, and future extensibility.

## 2. High-Level Architecture

```
                ┌─────────────────────┐
                │  Visual Builder UI  │
                │   / Playground      │
                └──────────┬──────────┘
                           │ Generic JSON
                           ▼
                ┌─────────────────────┐
                │    SDUI Engine      │
                │ Parser/SDK          │
                │ UiNode/UiDocument   │
                │ Registry            │
                │ Renderer            │
                │ PropertyResolver    │
                │ ActionResolver      │
                └──────────┬──────────┘
                           ▼
                  Native Flutter Widgets
```

**Dependency rule (strict):**
```
playground
   ↓
sdui_builder
   ↓
sdui_engine → Flutter
```
- `sdui_engine` never imports `sdui_builder` (no drag-drop, palette, inspector).
- `AppzillonPlugin` → `sdui_engine` registry (extension, not core).
- `CustomPlugin` → `sdui_engine` registry (host app).

## 3. Single Source of Truth

```
              UiNode Tree (UiDocument)
             /        |        \
            /         |         \
           ▼          ▼          ▼
        Canvas      JSON      Renderer (SduiView)
```

- `UiNode` `sdui_engine/lib/core/ui_node.dart:1` — `id, type, props, style, events, children`
- `UiDocument` `core/ui_document.dart:1` — `version + root`, helpers `findById, updateNode, insertChild, moveNode`
- Builder edits **only** the tree; serializer emits JSON; parser restores; renderer derives widgets. Widget tree is never the source.

## 4. No Giant Switch — Registry Pattern

```dart
// ❌ forbidden
switch(type) { case 'text': return Text(...) }

// ✅
registry.register('text', TextRenderer());
registry.register('appzillon.header', HeaderRenderer());
final r = registry.resolve(node.type) ?? UnknownRenderer();
r.render(node, ctx, childRenderer);
```

- `ComponentRegistry` `registry/component_registry.dart:1` stores `Map<String,ComponentRenderer>` **lower-cased** + alias map → case-insensitive (`sizedBox`/`SizedBox`/`SIZEDBOX` same).
- Adding a component = one `register` call, no core change (Open/Closed).

## 5. Flexible JSON Handling (Friend JSON Compatible)

Past friend JSON uses `singleChildScrollView` + `child` + top-level `value/label/padding`:
```json
{"type":"singleChildScrollView","child":{"type":"padding","padding":24,"child":{"type":"text","value":"Hi"}}}
```

**Parser** `core/ui_node.dart:73`:
- `child` (single Map) → `children:[childNode]` and `children` array both supported
- Flatten: any key not in `{type,props,style,events,children,child,id,version,root}` → `props` (so `value`, `label`, `padding:24` become props)
- `style` map preserved; renderers check **both** `props` and `style` via `PropertyResolver`
- `type` preserved as-is, registry resolves lower-cased

**Validator** `parser/sdui_validator.dart:1` lenient: `child` may be Map/List, extra keys ignored.

**Aliases** `built_in.dart:12` registers `sizedbox/sizedBox`, `singleChildScrollView/singlechildscrollview`, `elevatedButton/textButton/listTile` etc + `ComponentRegistry.registerAlias`.

## 6. Component System

**Generic Built-ins** `components/built_in.dart:1` (15 core + 18 generic):
`text, button, column, row, container, padding, center, stack, image, card, icon, divider, list, sizedbox, wrap, align, expanded, circleAvatar, singleChildScrollView, listView, gridView, listTile, elevatedButton, textButton, etc` + `SduiTheme` `theme/sdui_theme.dart:1` injectable.

**Fintech (Appzillon style)** `fintech_renderers.dart:1` + `generic_renderers.dart:1` — each implements `ComponentRenderer` `renderer/component_renderer.dart:1`.

**Appzillon Plugin** `appzillon/appzillon_plugin.dart:1`:
```dart
class AppzillonPlugin implements SduiPlugin {
  void register(SduiEngine e){
    e.componentRegistry.register('appzillon.header', HeaderRenderer());
    e.componentRegistry.register('header', HeaderRenderer()); // global alias
  }
}
```
Categories exactly: `Page(Header,Sidebar,Footer)`, `Popup(Modal,Dialog,PopOver)`, `Layout(Row,Column)`, `Panels(Simple Panel,Tab,Accordion,Carousel,Collapsible,Panel Section)`, `Containers(Breadcrumb,Chart,Form,Gauge,List,Menu,Navbar,Table)`, `Elements(Badge,Bullets,Button,CardNumber,Check,Dropdown...)` — `AppzillonComponentCatalog` `sdui_builder/lib/models/appzillon_catalog.dart:1` returns `List<ComponentDefinition>` grouped dynamically.

**ComponentDefinition** `sdui_builder/lib/models/component_definition.dart:1`:
```dart
class ComponentDefinition { String type; String label; String category; IconData icon; Map defaultProps/style/events; bool canHaveChildren; List<PropertyDefinition> properties; }
```
`createNode()` → `UiNode`.

**Property Inspector** `widgets/property_inspector.dart:1` generates controls from `PropertyCatalog.forType(type)` `models/property_definition.dart:1` (`string, number, boolean, enum, color, action`).

## 7. Renderer

`SduiRenderer` `renderer/sdui_renderer.dart:1`:
```dart
Widget renderNode(UiNode n, RenderContext ctx){
  final r = registry.resolve(n.type) ?? UnknownRenderer();
  return r.render(n, ctx, (child)=>renderNode(child, ctx));
}
```
- `UnknownComponentRenderer` shows `⚠ Unknown appzillon.some_future_component` amber, rest continues.
- `RenderContext` `renderer/render_context.dart:1` DI: `BuildContext, ComponentRegistry, ActionRegistry, SduiTheme, onAction, data`.

## 8. Actions

`Event → ActionRegistry → ActionHandler` `actions/action_handler.dart:1`
- Built-ins: `show_dialog, show_snackbar, navigate, callback, open_url, api`
- Host: `engine.registerAction('open_payment', OpenPaymentAction())` + JSON `{"events":{"onTap":{"action":"open_payment"}}}`
- `RenderContext.dispatchAction(map)` used by button/hyperlink etc.

## 9. Builder (Visual Playground)

`BuilderController` `state/builder_controller.dart:1` — `ChangeNotifier`, `UiDocument` + `selectedId` + `history` (50 steps) for undo/redo.

**Palette** `widgets/component_palette.dart:1`: `AppzillonComponentCatalog.grouped` dynamically → collapsible `_CategorySection` (6 Appzillon + legacy, deduplicated), search `TextField` filters `label/type/category`, generic `Draggable<ComponentDefinition>` (one mechanism).

**Canvas** `widgets/canvas.dart:52`: full-screen `Container(width/height:double.infinity, margin:8)` → `Stack(fit:expand, Positioned.fill(SingleChildScrollView))` → `_buildNode` recursion:
- `_canHaveChildren()` via `AppzillonComponentCatalog`/`ComponentCatalog` fallback
- `_canDrop(target,data)` + `_isDescendant` → `DragTarget.onWillAccept` → **red `#EF4444` border + `Not allowed`** if leaf (`Text`) → container `Form` invalid; blue `#3B82F6` if valid; `_wrapWithStyle` applies `color/padding/radius` so inspector edits live.
- Leaf → `_leafPreview` via `engine.renderer.renderNode` (accurate).
- Any leaf can be dropped directly onto blank `column` root (full hit area `SizedBox.expand`, `minHeight 80` placeholder) — no intermediate container needed.

**Header** `screens/builder_screen.dart:418` responsive `LayoutBuilder`: logo | `Flexible(title)` | `SingleChildScrollView(status chip)` | `Spacer` | `_HeaderActions` (always full `Load JSON`/`Generate JSON` `minimumSize 150×36`, never truncated).

**JSON Pipeline** `JsonPreviewDialog` `widgets/json_viewer.dart:1`: `UiTree → SduiSerializer → pretty JSON → Copy`; `Load JSON` (`FilePicker`/`Paste` → `parseJsonString` → `Validator` → `UiTree` → `Canvas`).

## 10. Tech Stack

- Flutter 3.47 / Dart 3.13 (Material 3, `SduiTheme`)
- Packages: `flutter`, `file_picker` (only non-Flutter dep)
- State: `ChangeNotifier` + immutable `UiDocument` copies

## 11. File Map

```
SDUI/
├─ packages/sdui_engine/lib
│  ├─ core/ ui_node, ui_document
│  ├─ parser/ sdui_parser, serializer, validator
│  ├─ registry/ component_registry, action_registry
│  ├─ renderer/ component_renderer, sdui_renderer, render_context
│  ├─ components/ built_in, text/button/layout/image/card/common, generic_renderers, fintech_renderers
│  ├─ appzillon/ appzillon_plugin, appzillon_renderers
│  ├─ plugin/ sdui_plugin (SduiPlugin)
│  └─ sdui.dart (SduiEngine, SduiView, SduiPlugin)
├─ packages/sdui_builder/lib
│  ├─ models/ component_definition, property_definition, appzillon_catalog
│  ├─ state/ builder_controller
│  ├─ widgets/ component_palette, canvas, property_inspector, json_viewer
│  └─ screens/ builder_screen
├─ apps/playground/lib/main.dart (engine.registerPlugin(AppzillonPlugin()) + custom.customer_card)
└─ docs/ APPZILLON_COMPONENTS.md, ARCHITECTURE.md, APPROACH.md
```

## 12. How to Embed

```dart
final engine = SduiEngine()..registerPlugin(AppzillonPlugin());
engine.registerComponent('custom.customer_card', CustomerCardRenderer());
SduiView(data: jsonFromServer, engine: engine)
```

Host JSON with `singleChildScrollView` + `value` / `header` (global) renders because engine has both `header` and `appzillon.header` aliases.

## 13. Principles

Genericity, Registry over switch, UI ≠ Engine, Plugin injection, `UiNode` single truth, extensible JSON, graceful unknown handling.
