import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_builder/sdui_builder.dart';
import 'package:sdui_engine/sdui_engine.dart';

void main() {
  test('builder controller add and generate json', () {
    final ctrl = BuilderController();
    expect(ctrl.document.root.children.isEmpty, isTrue);
    final def = ComponentCatalog.byType('text')!;
    ctrl.addNode(def);
    expect(ctrl.document.root.children.length, 1);
    expect(ctrl.selectedNode?.type, 'text');
    final jsonStr = ctrl.generateJson();
    expect(jsonStr.contains('text'), isTrue);
  });

  test('round-trip json reconstructs', () {
    final ctrl = BuilderController();
    ctrl.addNode(ComponentCatalog.byType('column')!);
    // add text inside column? select column then add text
    final colId = ctrl.selectedId!;
    ctrl.addNode(ComponentCatalog.byType('text')!, parentId: colId);
    ctrl.addNode(ComponentCatalog.byType('button')!, parentId: colId);
    final jsonMap = ctrl.generateJsonMap();
    final ctrl2 = BuilderController();
    ctrl2.loadFromJson(jsonMap);
    expect(ctrl2.document.root.children.length, 1);
    expect(ctrl2.document.root.children.first.children.length, 2);
  });

  test('property update', () {
    final ctrl = BuilderController();
    ctrl.addNode(ComponentCatalog.byType('text')!);
    ctrl.updateSelectedProps('props', 'text', 'Updated');
    expect(ctrl.selectedNode?.props['text'], 'Updated');
  });

  test('custom component injection via engine', () {
    final engine = SduiEngine();
    engine.registerComponent('my_custom', _DummyRenderer());
    final ctrl = BuilderController(engine: engine);
    final customNode = UiNode(type: 'my_custom', props: {'title': 'Hi'});
    ctrl.addNodeDirect(customNode);
    expect(ctrl.document.root.children.first.type, 'my_custom');
    final json = ctrl.generateJsonMap();
    // engine can parse custom type fine (validation only checks structure, not registered types)
    final doc = engine.parse(json);
    expect(doc.root.children.first.type, 'my_custom');
  });
}

class _DummyRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode p1) childRenderer,
  ) => const SizedBox.shrink();
  @override
  List<PropDescriptor> get propDescriptors => const [];
}
