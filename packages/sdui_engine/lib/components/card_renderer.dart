import 'package:flutter/material.dart';

import '../core/ui_node.dart';
import '../renderer/component_renderer.dart';
import '../renderer/render_context.dart';
import '../resolvers/property_resolver.dart';

class CardRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final style = node.style;
    final props = node.props;
    final elevation =
        PropertyResolver.doubleOrNull(style, 'elevation') ??
        PropertyResolver.doubleOrNull(props, 'elevation') ??
        2;
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 12;
    final margin = PropertyResolver.marginFrom(style);
    final padding = PropertyResolver.paddingFrom(style);
    final color =
        PropertyResolver.colorOrNull(style, 'color') ??
        PropertyResolver.colorOrNull(style, 'backgroundColor');

    Widget child;
    if (node.children.isEmpty) {
      final title = PropertyResolver.string(props, 'title', '');
      final subtitle = PropertyResolver.string(props, 'subtitle', '');
      if (title.isNotEmpty || subtitle.isNotEmpty) {
        child = Padding(
          padding: padding == EdgeInsets.zero
              ? const EdgeInsets.all(16)
              : padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ],
          ),
        );
      } else {
        child = Padding(
          padding: padding == EdgeInsets.zero
              ? const EdgeInsets.all(16)
              : padding,
          child: const Text('Card'),
        );
      }
    } else {
      final kids = node.children.map(childRenderer).toList();
      child = Padding(
        padding: padding == EdgeInsets.zero
            ? const EdgeInsets.all(12)
            : padding,
        child: kids.length == 1
            ? kids.first
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: kids,
              ),
      );
    }

    Widget w = Card(
      elevation: elevation,
      color: color ?? context.theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      margin: margin == EdgeInsets.zero ? const EdgeInsets.all(4) : margin,
      child: child,
    );

    final onTap = node.events['onTap'];
    if (onTap != null) {
      w = InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () {
          if (onTap is Map)
            context.dispatchAction(Map<String, dynamic>.from(onTap as Map));
          if (onTap is String) context.dispatchActionType(onTap);
        },
        child: w,
      );
    }
    return w;
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}
