# Extension Guide

Take `sdui_engine` into any Flutter app independently.

## Embed Engine Only (no Builder)
Add to your app's `pubspec.yaml`:
```yaml
dependencies:
  sdui_engine:
    path: ../packages/sdui_engine
    # or git: url: https://... version: ^0.1.0
```

```dart
import 'package:sdui_engine/sdui_engine.dart';

final engine = SduiEngine();
// optional theme
engine.theme = SduiTheme(primaryColor: Colors.deepPurple);

// use widget
SduiView(
  data: {
    "version":"1.0",
    "type":"column",
    "children":[{"type":"text","props":{"text":"Hello from server"}}]
  },
  engine: engine,
  onAction: (type, params) => print('Action $type $params'),
)
```

Network fetch example:
```dart
final json = await http.get(Uri.parse('https://api.example.com/ui')).then((r)=>jsonDecode(r.body));
setState(()=> _data=json);
SduiView(data:_data, engine:engine)
```

## Custom Component Injection
```dart
// lib/widgets/promo_banner.dart
class PromoBannerRenderer implements ComponentRenderer {
  @override Widget render(UiNode n, RenderContext c, Widget Function(UiNode) child) {
    return Container(color: Colors.orange, padding: EdgeInsets.all(16), child: Text(n.props['title'] ?? ''));
  }
  @override List<PropDescriptor> get propDescriptors => const [];
}

engine.registerComponent("promo_banner", PromoBannerRenderer());
// JSON: {"type":"promo_banner","props":{"title":"Sale 50% off"}}
```

## Custom Action Injection
```dart
class AnalyticsAction implements ActionHandler {
  @override Future<void> handle(RenderContext c, Map<String,dynamic> p) async {
    await analytics.logEvent(name: p['event']);
  }
}
engine.registerAction("analytics", AnalyticsAction());
// JSON: {"events":{"onTap":{"action":"analytics","event":"click_promo"}}}
```

## Build Your Own Builder
Depend on `sdui_engine` only; replicate `BuilderController` pattern: keep `UiDocument` as state, mutate via `updateNode/insertChild`, serialize via `engine.toJson`.

## No Engine Modification Needed
New components/actions never touch `packages/sdui_engine/lib/renderer/sdui_renderer.dart` — registry is the seam.
