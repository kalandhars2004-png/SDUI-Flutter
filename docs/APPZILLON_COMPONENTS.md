# Appzillon Components

Appzillon is provided as an **injectable plugin**, not hardcoded engine logic.

```
SduiEngine (generic)
   ↑
AppzillonPlugin  →  ComponentRegistry  →  Renderers  (appzillon.* namespace)
   ↑
CustomPlugin     →  custom.customer_card etc
```

Namespace `appzillon.*` prevents collisions with host custom components.

## Plugin Usage

```dart
import 'package:sdui_engine/sdui_engine.dart';
import 'package:sdui_engine/appzillon/appzillon_plugin.dart';

final engine = SduiEngine();
engine.registerPlugin(AppzillonPlugin()); // registers all 49+ Appzillon types

// Host custom alongside Appzillon
engine.registerComponent('custom.customer_card', CustomerCardRenderer());

SduiView(data: json, engine: engine)
```

Host can also use Appzillon catalog in its own builder:

```dart
import 'package:sdui_builder/models/appzillon_catalog.dart';
final defs = AppzillonComponentCatalog.all; // List<ComponentDefinition>
final grouped = AppzillonComponentCatalog.grouped; // Page, Popup, Layout, Panels, Containers, Elements
```

## Catalogue

Source: `packages/sdui_builder/lib/models/appzillon_catalog.dart:1` and `packages/sdui_engine/lib/appzillon/appzillon_plugin.dart:1` + `appzillon_renderers.dart:1`

Appzillon palette in Builder derives categories **dynamically** — no manual per-category UI lists. Each `ComponentDefinition` carries `category`, and `_CategorySection` is collapsed/expandable.

## Categories Overview

| Category | Count | Components |
|----------|-------|------------|
| Page | 3 | Header, Sidebar, Footer |
| Popup | 3 | Modal, Dialog, PopOver |
| Layout | 2 | Row, Column |
| Panels | 6 | Simple Panel, Tab, Accordion, Carousel, Collapsible, Panel Section |
| Containers | 8 | Breadcrumb, Chart, Form, Gauge, List, Menu, Navbar, Table |
| Elements | 28 | Badge, Bullets, Button, CardNumber, Check, Check Group, Dropdown, Dropdown List, External Link, File, Gauge, Hyperlink, Icon, Image, Input, Input with Button, Label, Progress Bar, Progress Steps, Radio, Separator, Slider, SortCode, SortCode List, Stepper, Tags, Text, Textarea, Toggle |

## Page

### appzillon.header — Header
- **Category:** Page
- **Accepts Children:** false (header actions as children optional)
- **Default Props:** `title: Header, subtitle: Welcome, backgroundColor: #0F172A`
- **Supported Props:** `title, subtitle`
- **Style:** `backgroundColor`
- **Events:** `onTap`
- **Renderer:** `AppzillonHeaderRenderer`
- **JSON:**
```json
{"type":"appzillon.header","props":{"title":"Good Morning","subtitle":"Welcome"},"style":{"backgroundColor":"#0F172A"}}
```

### appzillon.sidebar — Sidebar
- **Category:** Page
- **Accepts Children:** true
- **Default Props:** `title: Menu, width: 220`
- **Style:** `backgroundColor`
- **Renderer:** `AppzillonSidebarRenderer`
- **JSON:**
```json
{"type":"appzillon.sidebar","props":{"title":"Menu"},"children":[{"type":"appzillon.text","props":{"text":"Item"}}]}
```

### appzillon.footer — Footer
- **Category:** Page
- **Accepts Children:** false
- **Default Props:** `text: © 2026 Appzillon`
- **Renderer:** `AppzillonFooterRenderer`
```json
{"type":"appzillon.footer","props":{"text":"© 2026 Appzillon"}}
```

## Popup

### appzillon.modal — Modal
- **Accepts Children:** true
- **Default Props:** `title: Modal`
- **Style:** `borderRadius`
- **Renderer:** `AppzillonModalRenderer`
```json
{"type":"appzillon.modal","props":{"title":"Modal"},"children":[{"type":"appzillon.text","props":{"text":"Content"}}]}
```

### appzillon.dialog — Dialog
- **Accepts Children:** true
- **Default Props:** `title: Dialog, message: Dialog message`
- **Renderer:** `AppzillonDialogRenderer`

### appzillon.popover — PopOver
- **Accepts Children:** false
- **Default Props:** `text: PopOver`
- **Renderer:** `AppzillonPopOverRenderer`

## Layout

### appzillon.row — Row
- **Accepts Children:** true
- **Default Props:** `gap:12, padding:8`
- **Renderer:** `AppzillonRowRenderer` (flex + horizontal scroll, no switch)
```json
{"type":"appzillon.row","style":{"gap":12},"children":[{"type":"appzillon.button","props":{"text":"A"}}]}
```

### appzillon.column — Column
- **Accepts Children:** true
- **Default Props:** `gap:12, padding:12`
- **Renderer:** `AppzillonColumnRenderer`
```json
{"type":"appzillon.column","children":[{"type":"appzillon.text","props":{"text":"Hi"}}]}
```

## Panels

### appzillon.simple_panel — Simple Panel
- **Accepts Children:** true
- **Default Props:** `title: Panel`
- **Renderer:** `AppzillonSimplePanelRenderer`

### appzillon.tab — Tab
- **Accepts Children:** true
- **Default Props:** `label: Tab`
- **Renderer:** `AppzillonTabRenderer`

### appzillon.accordion — Accordion
- **Accepts Children:** true
- **Default Props:** `title: Accordion`
- **Renderer:** `AppzillonAccordionRenderer` (ExpansionTile)

### appzillon.carousel — Carousel
- **Accepts Children:** true
- **Renderer:** `AppzillonCarouselRenderer` (PageView, height 120)

### appzillon.collapsible — Collapsible
- **Accepts Children:** true
- **Default Props:** `title: Collapsible, collapsed: false`
- **Renderer:** `AppzillonCollapsibleRenderer`

### appzillon.panel_section — Panel Section
- **Accepts Children:** true
- **Default Props:** `title: Section`
- **Renderer:** `AppzillonPanelSectionRenderer` (left border accent)

## Containers

### appzillon.breadcrumb — Breadcrumb
- **Accepts Children:** true (or `items` array)
- **Default Props:** `items: [Home, Category, Current]`
- **Renderer:** `AppzillonBreadcrumbRenderer`

### appzillon.chart — Chart
- **Accepts Children:** true
- **Default Props:** `title: Chart, values: [30,60,45]`
- **Renderer:** `AppzillonChartRenderer`

### appzillon.form — Form
- **Accepts Children:** true
- **Default Props:** `title: Form`
- **Renderer:** `AppzillonFormRenderer`

### appzillon.gauge — Gauge
- **Accepts Children:** true
- **Default Props:** `value:0.65, label:65%`
- **Renderer:** `AppzillonGaugeRenderer` (CircularProgress)

### appzillon.list — List
- **Accepts Children:** true
- **Default Props:** `gap:8`
- **Renderer:** `AppzillonListRenderer`

### appzillon.menu — Menu
- **Accepts Children:** true (or `items`)
- **Default Props:** `items: [Item 1, Item 2]`
- **Renderer:** `AppzillonMenuRenderer`

### appzillon.navbar — Navbar
- **Accepts Children:** true
- **Default Props:** `title: Navbar, backgroundColor: #0F172A`
- **Renderer:** `AppzillonNavbarRenderer`

### appzillon.table — Table
- **Accepts Children:** true
- **Default Props:** `headers: [Col 1, Col 2], rows: [[Cell 1, Cell 2]]`
- **Renderer:** `AppzillonTableRenderer` (DataTable)

## Elements

| Type | Name | Accepts Children | Key Props | Events | Renderer |
|------|------|------------------|-----------|--------|----------|
| appzillon.badge | Badge | false | label, variant | onTap | AppzillonBadgeRenderer |
| appzillon.bullets | Bullets | false | items | — | AppzillonBulletsRenderer |
| appzillon.button | Button | false | text/label, enabled | onTap | AppzillonButtonRenderer |
| appzillon.card_number | CardNumber | false | number | — | AppzillonCardNumberRenderer |
| appzillon.check | Check | false | label, value | onChanged | AppzillonCheckRenderer |
| appzillon.check_group | Check Group | true | items | onChanged | AppzillonCheckGroupRenderer |
| appzillon.dropdown | Dropdown | false | hint, items, value | onChanged | AppzillonDropdownRenderer |
| appzillon.dropdown_list | Dropdown List | false | hint | onChanged | AppzillonDropdownListRenderer |
| appzillon.external_link | External Link | false | text, url | onTap | AppzillonExternalLinkRenderer |
| appzillon.file | File | false | name, size | — | AppzillonFileRenderer |
| appzillon.hyperlink | Hyperlink | false | text, url | onTap | AppzillonHyperlinkRenderer |
| appzillon.icon | Icon | false | icon, size | — | AppzillonIconRenderer |
| appzillon.image | Image | false | src, height | — | AppzillonImageRenderer |
| appzillon.input | Input | false | label, hint, value, required | onChanged | AppzillonInputRenderer |
| appzillon.input_with_button | Input with Button | false | hint, buttonText | onTap | AppzillonInputWithButtonRenderer |
| appzillon.label | Label | false | text, color | — | AppzillonLabelRenderer |
| appzillon.progress_bar | Progress Bar | false | value | — | AppzillonProgressBarRenderer |
| appzillon.progress_steps | Progress Steps | false | steps, current | — | AppzillonProgressStepsRenderer |
| appzillon.radio | Radio | false | label, value | onChanged | AppzillonRadioRenderer |
| appzillon.separator | Separator | false | thickness, color, margin | — | AppzillonSeparatorRenderer |
| appzillon.slider | Slider | false | value, min, max | onChanged | AppzillonSliderRenderer |
| appzillon.sort_code | SortCode | false | code | — | AppzillonSortCodeRenderer |
| appzillon.sort_code_list | SortCode List | true | items | — | AppzillonSortCodeListRenderer |
| appzillon.stepper | Stepper | false | value | onChanged | AppzillonStepperRenderer |
| appzillon.tags | Tags | false | items | — | AppzillonTagsRenderer |
| appzillon.text | Text | false | text, fontSize, color | onTap | AppzillonTextRenderer |
| appzillon.textarea | Textarea | false | label, hint, value | onChanged | AppzillonTextareaRenderer |
| appzillon.toggle | Toggle | false | label, value | onChanged | AppzillonToggleRenderer |

Example **appzillon.text**:
```json
{"type":"appzillon.text","props":{"text":"Welcome"},"style":{"fontSize":18,"color":"#0F172A"}}
```

Example **with children**:
```json
{
  "version":"1.0",
  "type":"appzillon.column",
  "children":[
    {"type":"appzillon.text","props":{"text":"Welcome"}},
    {"type":"appzillon.button","props":{"text":"Continue"},"events":{"onTap":{"action":"show_snackbar","message":"Go"}}}
  ]
}
```

## Generic ComponentDefinition

```dart
class ComponentDefinition {
  final String type; // e.g., appzillon.text
  final String name; // alias label
  final String category;
  final IconData icon;
  final Map<String, dynamic> defaultProps;
  final List<PropertyDefinition> properties;
  final bool acceptsChildren; // also canHaveChildren
}
```

Builder receives definitions from `AppzillonComponentCatalog.all` → groups by `category` → collapsible sections (`Page`, `Popup`, etc.) → each item uses **one generic drag** path:

`ComponentDefinition → create UiNode → insert into UiTree → Canvas rebuilds → Registry resolves Renderer → Widget`

No per-component drag code.

## Unknown Component

If JSON contains unregistered `"type":"appzillon.some_future_component"`, engine renders `UnknownComponentRenderer`:

```
┌─────────────────────────┐
│ ⚠ Unknown Component     │
│ appzillon.some_future…  │
└─────────────────────────┘
```

Canvas continues; validation still passes (type present, children valid), but renderer falls back.

## Extending with Custom

```dart
final engine = SduiEngine()..registerPlugin(AppzillonPlugin());
engine.registerComponent('custom.customer_card', CustomerCardRenderer());
// appears alongside appzillon.* without touching AppzillonPlugin
```

## File Map

- `packages/sdui_engine/lib/appzillon/appzillon_catalog.dart` — definitions (if using builder catalog: `packages/sdui_builder/lib/models/appzillon_catalog.dart`)
- `packages/sdui_engine/lib/appzillon/appzillon_renderers.dart` — all renderers
- `packages/sdui_engine/lib/appzillon/appzillon_plugin.dart` — `AppzillonPlugin implements SduiPlugin`
- `packages/sdui_builder/lib/models/appzillon_catalog.dart` — builder-side catalogue (mirrors engine types for UI)
- `packages/sdui_builder/lib/widgets/component_palette.dart` — shows `APPZILLON COMPONENTS` with collapsible + search
- `packages/sdui_engine/lib/plugin/sdui_plugin.dart` — `SduiPlugin` interface
- Engine remains generic: `packages/sdui_engine/lib/components/built_in.dart` only registers core/generic widgets, not Appzillon.

## JSON Pipeline

Generate: `UiTree → SduiSerializer → JSON` (preserves `appzillon.*` type)

Import: `JSON → SduiParser (supports child/children, flattened props, case-insensitive) → Validator → UiTree → Canvas` — same registry used, no separate import renderer.

Also supports legacy/alternate schemas: `child` vs `children`, top-level `value/label/padding` flattened into `props`, `sizedBox/elevatedButton` aliases etc., enabling the pasted example with `singleChildScrollView` + `padding:24` + `value:` to render.
