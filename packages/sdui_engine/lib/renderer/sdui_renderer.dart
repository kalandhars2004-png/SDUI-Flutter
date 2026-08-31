import 'package:flutter/material.dart';

import '../core/ui_node.dart';
import '../registry/component_registry.dart';
import 'component_renderer.dart';
import 'render_context.dart';

class SduiRenderer {
  final ComponentRegistry componentRegistry;
  final ComponentRenderer fallbackRenderer;

  SduiRenderer({
    required this.componentRegistry,
    ComponentRenderer? fallbackRenderer,
  }) : fallbackRenderer = fallbackRenderer ?? UnknownComponentRenderer();

  Widget renderNode(UiNode node, RenderContext context) {
    // Resolve via registry - no switch!
    final renderer = componentRegistry.resolve(node.type) ?? fallbackRenderer;
    try {
      return renderer.render(
        node,
        context,
        (child) => renderNode(child, context),
      );
    } catch (e, st) {
      debugPrint('[SDUI] Render error for ${node.type}: $e\n$st');
      return ErrorComponentRenderer('Render error: ${node.type} - $e')
          .render(node, context, (c) => renderNode(c, context));
    }
  }

  Widget renderList(List<UiNode> nodes, RenderContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: nodes.map((n) => renderNode(n, context)).toList(),
    );
  }
}
