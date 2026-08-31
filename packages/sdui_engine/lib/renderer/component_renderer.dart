import 'package:flutter/material.dart';

import '../core/ui_node.dart';
import 'render_context.dart';

/// Interface every component must implement. No switch-case in core renderer.
abstract class ComponentRenderer {
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  );

  /// Optional: describe expected props for tooling / builder inspector.
  List<PropDescriptor> get propDescriptors => const [];
}

class PropDescriptor {
  final String key;
  final String label;
  final String type; // string, number, boolean, enum, color, etc
  final dynamic defaultValue;
  final List<String>? enumValues;
  const PropDescriptor({
    required this.key,
    required this.label,
    required this.type,
    this.defaultValue,
    this.enumValues,
  });
}

/// Fallback for unknown component types.
class UnknownComponentRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber.shade700,
            size: 18,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Unknown component',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade900,
                  ),
                ),
                Text(
                  'type: ${node.type}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.amber.shade800,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

/// Fallback for invalid/error nodes.
class ErrorComponentRenderer implements ComponentRenderer {
  final String message;
  ErrorComponentRenderer(this.message);
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}
