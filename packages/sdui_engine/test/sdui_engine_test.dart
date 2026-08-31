import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/sdui_engine.dart';

void main() {
  group('UiNode', () {
    test('creation and json roundtrip', () {
      final node = UiNode(
        type: 'text',
        props: {'text': 'Hello'},
        style: {'fontSize': 16},
        children: [],
      );
      final json = node.toWireJson();
      expect(json['type'], 'text');
      final restored = UiNode.fromJson(json);
      expect(restored.type, node.type);
      expect(restored.props['text'], 'Hello');
    });

    test('document roundtrip', () {
      const raw = {
        'version': '1.0',
        'type': 'column',
        'children': [
          {
            'type': 'text',
            'props': {'text': 'Hi'},
          },
          {
            'type': 'button',
            'props': {'text': 'Go'},
          },
        ],
      };
      final engine = SduiEngine();
      final doc = engine.parse(raw);
      expect(doc.root.type, 'column');
      expect(doc.root.children.length, 2);
      final json = engine.toJson(doc);
      final doc2 = engine.parse(json);
      expect(doc2.root.children.length, 2);
      expect(doc2.root.children.first.props['text'], 'Hi');
    });

    test('validation fails on missing type', () {
      final validator = SduiValidator.validate({'version': '1.0', 'props': {}});
      expect(validator.isValid, isFalse);
      expect(validator.errors.isNotEmpty, isTrue);
    });

    test('registry resolves and fallback works', () {
      final engine = SduiEngine();
      expect(engine.componentRegistry.contains('text'), isTrue);
      expect(engine.componentRegistry.contains('custom_xyz_123'), isFalse);
      // custom registration
      engine.registerComponent('custom_banner', _DummyRenderer());
      expect(engine.componentRegistry.contains('custom_banner'), isTrue);
    });

    test('action registry', () {
      final engine = SduiEngine();
      expect(engine.actionRegistry.contains('show_dialog'), isTrue);
      engine.registerAction('my_action', _DummyAction());
      expect(engine.actionRegistry.contains('my_action'), isTrue);
    });

    test('unknown component does not crash', () {
      final engine = SduiEngine();
      const json = {
        'version': '1.0',
        'type': 'column',
        'children': [
          {
            'type': 'unknown_type_xyz',
            'props': {'foo': 'bar'},
          },
          {
            'type': 'text',
            'props': {'text': 'After unknown'},
          },
        ],
      };
      final doc = engine.parse(json);
      expect(doc.root.children.length, 2);
      expect(doc.root.children.first.type, 'unknown_type_xyz');
    });

    test('recursive children', () {
      const json = {
        'version': '1.0',
        'type': 'column',
        'children': [
          {
            'type': 'card',
            'children': [
              {
                'type': 'text',
                'props': {'text': 'Nested'},
              },
              {
                'type': 'row',
                'children': [
                  {
                    'type': 'icon',
                    'props': {'icon': 'star'},
                  },
                  {
                    'type': 'text',
                    'props': {'text': 'Item'},
                  },
                ],
              },
            ],
          },
        ],
      };
      final engine = SduiEngine();
      final doc = engine.parse(json);
      expect(doc.root.children.first.children.length, 2);
      expect(doc.root.children.first.children[1].children.length, 2);
    });
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

class _DummyAction implements ActionHandler {
  @override
  Future<void> handle(
    RenderContext context,
    Map<String, dynamic> params,
  ) async {}
}
