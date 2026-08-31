# Development

## Prereqs
- Flutter 3.47+ (Dart 3.13). Check `flutter --version`.
- Enable Developer Mode on Windows for symlink support (`start ms-settings:developers`).

## Structure
```
project/
├─ packages/sdui_engine   # standalone engine
├─ packages/sdui_builder  # drag-drop UI, depends on engine
├─ apps/playground        # demo app, depends on both
└─ docs/
```

## Setup
```bash
cd packages/sdui_engine && flutter pub get
cd ../sdui_builder && flutter pub get
cd ../../apps/playground && flutter pub get
```

## Run Playground
```bash
cd apps/playground
flutter run -d windows    # or -d chrome
```
Hot reload works. Builder is at `localhost`.

## Analyze & Test
```bash
flutter analyze            # in each package/app
flutter test               # engine (7 tests), builder (4 tests), playground (1)
```

## Code Style
- SOLID, DI via `RenderContext`, composition over inheritance.
- Null safety, no global mutable state (except engine registries which are intentionally mutable via `register`).
- Keep files small; no god classes.
- `file_picker` only third-party beyond Flutter for file IO.

## Adding Components
1. Create `my_renderer.dart` implementing `ComponentRenderer`.
2. Register in `built_in.dart` or let host register.
3. Add `PropertyDefinition` in `property_definition.dart` for builder inspector.
4. Add `ComponentDefinition` in `component_definition.dart` for palette.

## Conventions
- Props = data, Style = visuals, Events = actions — keep separation.
- Use `PropertyResolver` for parsing style values (don't reimplement hex parsing).
- Registry keys are snake_case (`profile_card`).

## CI ideas
- `flutter analyze --fatal-infos`
- `flutter test`
- `flutter build web` for playground
