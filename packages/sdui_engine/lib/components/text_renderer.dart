import 'package:flutter/material.dart';

import '../core/ui_node.dart';
import '../renderer/component_renderer.dart';
import '../renderer/render_context.dart';
import '../resolvers/property_resolver.dart';

class TextRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final text = PropertyResolver.string(
      props,
      'text',
      props['value']?.toString() ?? 'Text',
    );
    final fontSize =
        PropertyResolver.doubleOrNull(style, 'fontSize') ??
        PropertyResolver.doubleOrNull(props, 'fontSize');
    final color =
        PropertyResolver.colorOrNull(style, 'color') ??
        PropertyResolver.colorOrNull(props, 'color');
    final weight = PropertyResolver.fontWeightFrom(
      style['fontWeight'] ?? props['fontWeight'],
    );
    final align = PropertyResolver.textAlignFrom(
      style['textAlign'] ?? props['textAlign'],
    );
    final maxLines = props['maxLines'] is int ? props['maxLines'] as int : null;
    final overflow = props['overflow'] == 'ellipsis'
        ? TextOverflow.ellipsis
        : null;

    final fontFamily = style['fontFamily'] as String? ?? props['fontFamily'] as String?;
    final letterSpacing = PropertyResolver.doubleOrNull(style, 'letterSpacing') ?? PropertyResolver.doubleOrNull(props, 'letterSpacing');
    final lineHeight = PropertyResolver.doubleOrNull(style, 'lineHeight') ?? PropertyResolver.doubleOrNull(props, 'lineHeight');

    final padding = PropertyResolver.paddingFrom(style);
    final margin = PropertyResolver.marginFrom(style);

    Widget w = Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize,
        color: color ?? context.theme.textColor,
        fontWeight: weight,
        fontFamily: fontFamily,
        letterSpacing: letterSpacing,
        height: lineHeight,
      ),
    );
    if (padding != EdgeInsets.zero) w = Padding(padding: padding, child: w);
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);

    // events: onTap
    final onTap = node.events['onTap'] ?? node.events['onClick'];
    if (onTap is Map) {
      w = InkWell(
        onTap: () =>
            context.dispatchAction(Map<String, dynamic>.from(onTap as Map)),
        child: w,
      );
    } else if (onTap is String) {
      w = InkWell(onTap: () => context.dispatchActionType(onTap), child: w);
    }
    return w;
  }

  @override
  List<PropDescriptor> get propDescriptors => const [
    PropDescriptor(
      key: 'text',
      label: 'Text',
      type: 'string',
      defaultValue: 'Hello',
    ),
    PropDescriptor(
      key: 'fontSize',
      label: 'Font Size',
      type: 'number',
      defaultValue: 14,
    ),
    PropDescriptor(key: 'color', label: 'Color', type: 'color'),
    PropDescriptor(
      key: 'fontWeight',
      label: 'Weight',
      type: 'enum',
      enumValues: ['normal', 'medium', 'bold', 'w700'],
    ),
  ];
}
