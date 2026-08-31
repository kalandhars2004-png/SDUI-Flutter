# JSON Pipeline

Round-trip must work losslessly: drag → generate → save → load → identical canvas.

## Forward: Canvas → JSON
```
Canvas Tree (UiDocument)
    ↓ BuilderController.generateJson()
UiDocument → SduiSerializer.toJson / toJsonString
    ↓
Formatted JSON string (wire format, no internal ids unless requested)
    ↓
JsonPreviewDialog (copyable, monospace on Color(0xFF0F172A))
```

- `BuilderController.generateJson(pretty:true, includeIds:false)` (`packages/sdui_builder/lib/state/builder_controller.dart:117`) calls `engine.toJsonString(_document)`.
- `SduiSerializer` (`packages/sdui_engine/lib/parser/sdui_serializer.dart:1`) uses `UiNode.toWireJson()` (omits `id`) vs `toJson()` (includes `id` for history).
- Viewer: `packages/sdui_builder/lib/widgets/json_viewer.dart:1` — `JsonPreviewDialog` (Dialog 640×520) and `JsonViewerSheet` (BottomSheet). Both have Copy via `Clipboard`.

## Reverse: JSON → Canvas
```
File Picker / Paste JSON
    ↓
String content
    ↓
BuilderController.loadFromJsonString(content)
    ↓
SduiParser.parseJsonString → jsonDecode → SduiValidator.validate → UiDocument.fromJson
    ↓
_document = newDoc; _selectedId = null; notifyListeners()
    ↓
Canvas rebuilds via _buildNode recursion
```

- File picker: `file_picker: ^10.1.0`, `withData:true` to work on Web; bytes decoded as utf8.
- Paste: `AlertDialog` with 14-line `TextField`.
- Validation errors show `SnackBar` + `AlertDialog` with `SduiParseException.toString()`. No silent ignore.
- Both drag/drop tree and imported JSON converge to same `UiNode` model — no separate renderer.

## Validation Before Render
`SduiValidator.validate` checks `version,type,props,children`. `SduiParser` throws if invalid; `SduiEngine.parse` wraps; `SduiView` catches and shows `_errorWidget` instead of crash.

## Test Scenario
- **A**: Drag `Column` → add `Text`, `Button`, `Card` → Generate JSON → asserts `type:column` with 3 children.
- **B**: Load that JSON → `Canvas` reconstructs exact tree (controller test `round-trip json reconstructs`).
- **C**: JSON with `profile_card` (custom injected) renders without engine change ( `_DemoTab` scenario C).

## Id Handling
Builder retains stable `id`s internally for selection/history. Wire JSON omits ids for server portability; re-import generates new ids but structure identical.
