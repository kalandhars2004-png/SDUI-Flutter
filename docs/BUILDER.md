# Builder

Package `packages/sdui_builder` — visual editor, no rendering logic duplicated.

## 3-Zone Layout
`packages/sdui_builder/lib/screens/builder_screen.dart:12`

```
┌──────────────────────────────────────────────┐
│ Header: SDUI Builder | Engine: Connected | [Load JSON] [Generate JSON] |
├──────────┬─────────────────────┬──────────────┤
│ Palette  │     Canvas          │ Inspector    │
│ 260px    │     flex            │ 320px        │
└──────────┴─────────────────────┴──────────────┘
```
Responsive: `LayoutBuilder` switches to vertical stacking on <900px (palette+canvas row, inspector below). Header uses `LayoutBuilder` to hide subtitle/status on narrow widths and scrolls actions horizontally.

## State
`packages/sdui_builder/lib/state/builder_controller.dart:7` — `BuilderController extends ChangeNotifier`

- Holds `UiDocument _document` (source of truth) and `String? _selectedId`.
- Mutations produce new `UiDocument` via `UiDocument.updateNode` etc., enabling history.
- `_history` list + `_historyIndex` for undo/redo; `_pushHistory` caps at 50.
- Methods: `addNode(def, {parentId})`, `addNodeDirect(node)`, `deleteSelected`, `updateSelectedProps(group,key,value)`, `moveNode`, `reorderInParent`, `duplicateSelected`, `generateJson`, `loadFromJsonString`, `undo`, `redo`, `clear`.
- `canHaveChildren` set: `column,row,container,card,list,stack,padding,center`. Leaf selection falls back to root.

## Palette
`packages/sdui_builder/lib/widgets/component_palette.dart:1`

- Data: `ComponentDefinition` (`packages/sdui_builder/lib/models/component_definition.dart:1`) — `type,label,category,icon,defaultProps,defaultStyle,canHaveChildren`.
- `ComponentCatalog.all` grouped by `Layout|Basic|Content`. Dynamically generates palette; adding a definition auto-appears.
- Drag: `Draggable<ComponentDefinition>` + `LongPressDraggable` for mobile/desktop, feedback widget is compact card, `childWhenDragging` opacity 0.4.

## Canvas
`packages/sdui_builder/lib/widgets/canvas.dart:1`

- Centered white card (maxWidth 520, shadow, rounded 16) on `Color(0xFFF1F5F9)` background.
- Root is `DragTarget<ComponentDefinition>` — `onAcceptWithDetails` → `controller.addNode`.
- Recursively builds `_buildNode`: leaf nodes delegate to `engine.renderer.renderNode` for accurate preview via `RenderContext`; container nodes show placeholder or styled children with gap spacing.
- Selection: `isSelected` draws `Color(0xFF0F172A)` border 1.5 + top-right copy/delete micro-bar. Hover shows blue border.
- Draggable `UiNode` for reordering/reparenting; `DragTarget<Object>` accepts both `ComponentDefinition` (add) and `UiNode` (move).
- Empty state shows `dashboard_customize` icon + hints.

## Property Inspector
`packages/sdui_builder/lib/widgets/property_inspector.dart:1`

- `AnimatedBuilder` listening to `BuilderController`. If `selectedNode==null` shows empty state.
- `PropertyCatalog.forType` (`packages/sdui_builder/lib/models/property_definition.dart:1`) returns `List<PropertyDefinition>` grouped by `props|style|events`.
- Generic controls per `type`: `string`→`TextField`, `number`→number field, `boolean`→`Switch`, `enum`→`Dropdown`, `color`→hex field + swatch, `action`→dropdown (`none, show_dialog, show_snackbar, navigate, callback, open_url`).
- Updates via `controller.updateSelectedProps(group,key,value)` — value `null` removes key.
- Danger zone: Duplicate, Delete.

## JSON Buttons
Header `_HeaderActions` provides Generate (opens `JsonPreviewDialog`) and Load (file_picker or paste). See `JSON_PIPELINE`.
