# SDUI Flutter — Generic Server-Driven UI + MySQL GraphQL Server

> **JSON → UiNode Tree → ComponentRegistry → Renderer → Flutter Widget**
> Server (Spring Boot + GraphQL + MySQL) is **just a JSON store** — Flutter `SduiEngine` stays generic and injectable.

A complete SDUI system: **visual Builder** (drag-drop) + **generic Engine** + **Java server** that stores JSON in MySQL and serves it strictly via GraphQL. Main drag-drop screen and Manage screen share the same `UiNode` tree — edit, save as new, or update existing.

---

## How It Works (Pixel by Pixel liked)

**1. JSON in** — paste / pick file / fetch from server:
```json
{"type":"column","children":[{"type":"text","props":{"text":"Hi"}}]}
```
Supports `child` vs `children`, top-level `value/label/padding` flattened to `props`, case-insensitive `sizedBox/SizedBox`.

**2. Parser** `sdui_engine/lib/parser/sdui_parser.dart:1` → `SduiValidator` → `UiNode.fromJson` `core/ui_node.dart:73` (handles `child`, `_reserved` flatten).

**3. Tree** `UiDocument(version, root: UiNode)` — single source for canvas, JSON, preview.

**4. Registry** `registry/component_registry.dart:1` — `Map lowerType → Renderer` + alias. No `switch(type)`.  
`built_in.dart` registers core (`text`, `column`), `generic_renderers.dart` registers `singleChildScrollView/listTile/elevatedButton`, `AppzillonPlugin` registers `header/input` both as `header` and `appzillon.header`.

**5. Renderer** `renderer/sdui_renderer.dart:1` → `registry.resolve(type) ?? UnknownRenderer` → `renderer.render(node, ctx, child=>renderNode(child))` → native `Text/Container/Row`.

**6. Paint** `RenderParagraph/RenderFlex` → `Canvas.drawParagraph` → GPU pixels.

**Builder ↔ Server flow:**
```
[Manage JSON Screen] --GraphQL mutation saveTemplate(name,json)--> [Spring Boot :8080/graphql] --JPA--> [MySQL sdui.sdui_template]
[Manage JSON Screen] --GraphQL query templates--> [Spring Boot] --SELECT *--> [MySQL] --json--> list
[Load UI] --t.json--> BuilderController.loadFromJsonStringAsync(json, templateId, templateName) --> _document = newDoc --> canvas + preview auto update (AnimatedBuilder)
[Builder header Save to DB] --generateJsonAsync()--> json --GraphQL updateTemplate/saveTemplate--> MySQL (create new or update)
```
`SduiEngine` never talks to MySQL directly — strictly `GraphQL` API level.

---

## Architecture

```
                      ┌─────────────────────┐
                      │  Playground (Flutter)│
                      │  ┌──────────────┐   │
                      │  │Builder       │   │
                      │  │Palette|Canvas│   │
                      │  │Inspector     │   │
                      │  └──────┬───────┘   │
                      │         │ UiNode    │
                      │  ┌──────▼───────┐   │
                      │  │ Manage JSON  │◄──┼── GraphQL (graphql_flutter)
                      │  │paste/pick/   │   │   templates/saveTemplate
                      │  │list/Load UI  │   │
                      │  └──────────────┘   │
                      └──────────┬──────────┘
                                 │ json String
                                 ▼
                      ┌─────────────────────┐
                      │   SDUI Engine       │  ← generic, no Builder import
                      │ Parser/Validator    │
                      │ UiNode/UiDocument   │
                      │ ComponentRegistry   │◄── AppzillonPlugin + custom.customer_card
                      │ Renderer            │
                      └──────────┬──────────┘
                                 │ Widget
                                 ▼
                         Flutter Widgets
                                 │
                      ┌──────────┴──────────┐
                      │  SDUI-Server (Java) │
                      │ Spring Boot 3.2.5   │
                      │ GraphQL /graphql    │
                      │ JPA → MySQL 8      │
                      │ sdui_template       │
                      └─────────────────────┘
```

**Dependency:** `playground → sdui_builder → sdui_engine → Flutter` ; `AppzillonPlugin → sdui_engine` ; `Manage Screen --GraphQL--> Server --JPA--> MySQL`

---

## Project Structure

```
D:\MONTH-2\week-5\Flutter\SDUI\              # Flutter SDUI (this repo)
├─ packages/sdui_engine/lib
│  ├─ core/ ui_node, ui_document
│  ├─ parser/ sdui_parser, validator, serializer
│  ├─ registry/ component_registry (case-insensitive), action_registry
│  ├─ renderer/ component_renderer, sdui_renderer, render_context
│  ├─ components/ built_in, generic_renderers, fintech_renderers
│  ├─ appzillon/ appzillon_plugin, appzillon_renderers
│  └─ sdui.dart (SduiEngine, SduiView, SduiPlugin)
├─ packages/sdui_builder/lib
│  ├─ models/ component_definition, property_definition, appzillon_catalog (6 categories)
│  ├─ state/ builder_controller (clone, history 50/15, loadFromJsonStringAsync)
│  └─ screens/ builder_screen (full-screen canvas, red invalid border, Save to DB)
├─ apps/playground/lib
│  ├─ main.dart (4 tabs: Builder | Preview | Demo | Manage JSON)
│  ├─ services/sdui_graphql_service.dart (HttpLink 127.0.0.1:8080/graphql)
│  └─ screens/manage_json_screen.dart (paste/pick/list/Load UI → auto-redirect)
└─ docs/ APPZILLON_COMPONENTS.md, APPROACH.md, ARCHITECTURE.md

D:\MONTH-2\week-5\Flutter\SDUI-Server\      # Java Server (outside, as you asked)
├─ pom.xml (spring-boot-starter-web, graphql, data-jpa, mysql-connector-j)
├─ src/main/resources/application.yml (datasource: jdbc:mysql://127.0.0.1:3306/sdui, root/root, ddl-auto:update, graphiql enabled)
├─ src/main/resources/graphql/schema.graphqls
└─ src/main/java/com/sdui/server
   ├─ entity/SduiTemplate.java (id UUID, name, json LONGTEXT, version, createdAt)
   ├─ repository/SduiTemplateRepository.java
   ├─ service/SduiTemplateService.java (validate type, save/update/delete)
   └─ graphql/SduiTemplateController.java (@QueryMapping templates, @MutationMapping saveTemplate)
```

---

## Run — Flutter + Server (MySQL, strictly GraphQL)

**1. MySQL (local, no Docker as you said):**
- Service `MySQL80` Running, `root/root`, DB `sdui` auto-created (`createDatabaseIfNotExist=true`)

**2. Server:**
```bash
cd D:\MONTH-2\week-5\Flutter\SDUI-Server
mvn spring-boot:run
# → Tomcat 8080, GraphQL http://127.0.0.1:8080/graphql, GraphiQL http://127.0.0.1:8080/graphiql
```

**3. Flutter:**
```bash
cd D:\MONTH-2\week-5\Flutter\SDUI\apps\playground
flutter pub get
flutter run -d web-server --web-port=8082 --web-hostname=127.0.0.1
# → http://127.0.0.1:8082
```
Or `flutter run -d chrome`

**4. Use:**
- **Builder tab** — drag `Header/Text/Button` (APPZILLON COMPONENTS 49, search, collapsible) → edit props → canvas full-screen, red border if leaf→leaf invalid
- **Manage JSON tab** — paste JSON or `Pick JSON file` + Name → `Save to MySQL (GraphQL)` → list shows `templates` from MySQL → `Load UI` → auto `controller.loadFromJsonStringAsync(json, templateId)` → redirects to Builder tab and canvas reconstructs (same `UiNode` tree)
- **After edit** — Builder header now shows `Update DB` (if loaded, shows `id 8chars`) + `Save as New` → `Save to DB` → `updateTemplate` vs `saveTemplate` via GraphQL → MySQL `LONGTEXT` updated
- **Preview tab** — `SduiView(data: controller.generateJsonMap(), engine: engine)` live, handles `singleChildScrollView` root without double scroll

**GraphQL strictly:**
```graphql
query { templates { id name json version } }
mutation { saveTemplate(name:"Home", json:"{\"type\":\"column\"...}") { id } }
mutation { updateTemplate(id:"...", json:"...") { id } }
```

---

## Why This Approach

- **Generic:** One engine for any JSON (friend's `singleChildScrollView` with `value`, Appzillon `header`, custom `customer_card` all via same `register`).
- **No switch:** Registry pattern → Open/Closed, testable.
- **Plugin:** `AppzillonPlugin` proves extension without core change; host `custom.*` works alongside.
- **Single truth:** `UiNode` tree → canvas, JSON, preview all derive, `Generate ↔ Load` round-trip guaranteed.
- **API-level MySQL:** Flutter never touches DB, only `String json` via GraphQL; MySQL `sdui_template` is dumb store.

---

## Test

```bash
flutter test --directory packages/sdui_engine  # pasted_json_test: singleChildScrollView child→children
flutter test --directory packages/sdui_builder # pasted_full_test: Column 13 children
# GraphQL: curl -X POST http://127.0.0.1:8080/graphql -d '{"query":"{templates{id name}}"}'
```

MIT
