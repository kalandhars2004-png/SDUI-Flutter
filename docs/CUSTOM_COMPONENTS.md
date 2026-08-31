# Custom Components

Host apps extend SDUI without forking engine.

## Minimal Example
```dart
// 1. Define renderer
import 'package:sdui_engine/sdui_engine.dart';
import 'package:flutter/material.dart';

class ProductCardRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext ctx, Widget Function(UiNode) childRenderer) {
    final title = node.props['title'] ?? 'Sample Product';
    return Card(child: Text(title));
  }
  @override List<PropDescriptor> get propDescriptors => const [];
}

// 2. Register before rendering
final engine = SduiEngine();
engine.registerComponent("product_card", ProductCardRenderer());

// 3. JSON now works
// {"type":"product_card","props":{"title":"Headphones"}}
```

## Real Demo
`apps/playground/lib/widgets/custom_components.dart:1` defines `ProfileCardRenderer` and `ProductCardRenderer` and registers them in `apps/playground/lib/main.dart:28`:

```dart
engine.registerComponent('profile_card', ProfileCardRenderer());
engine.registerComponent('product_card', ProductCardRenderer());
engine.registerComponent('custom_card', ProfileCardRenderer());
```

`apps/playground/lib/main.dart:239` JSON uses `profile_card` and `product_card` without engine changes — proof of genericity.

## Props via PropertyResolver
Use `PropertyResolver` helpers to parse `props`/`style` consistently (color hex, padding, etc.). See `packages/sdui_engine/lib/resolvers/property_resolver.dart:1`.

## Builder Descriptor (optional)
If you want the visual builder to show your custom type, add a `ComponentDefinition` in `packages/sdui_builder/lib/models/component_definition.dart:1`:

```dart
ComponentDefinition(type:'profile_card', label:'Profile Card', category:'Content', icon:Icons.person, defaultProps:{'name':'Demo User'})
```
But even without that, the engine still renders it; builder drag-drop is just tooling.

## Overriding Built-ins
Registering `engine.registerComponent("text", MyTextRenderer())` replaces the default text renderer — useful for brand typography.

## Testing Custom
```dart
engine.registerComponent('my_custom', _DummyRenderer());
final ctrl = BuilderController(engine: engine);
ctrl.addNodeDirect(UiNode(type:'my_custom', props:{'title':'Hi'}));
expect(ctrl.document.root.children.first.type, 'my_custom');
```
