import 'package:flutter/material.dart';

import '../core/ui_node.dart';
import '../renderer/component_renderer.dart';
import '../renderer/render_context.dart';
import '../resolvers/property_resolver.dart';

class ButtonRenderer implements ComponentRenderer {
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
      PropertyResolver.string(props, 'label', 'Button'),
    );
    final variant = PropertyResolver.string(
      props,
      'variant',
      PropertyResolver.string(style, 'variant', 'elevated'),
    );
    final bg =
        PropertyResolver.colorOrNull(props, 'backgroundColor') ??
        PropertyResolver.colorOrNull(style, 'backgroundColor');
    final fg =
        PropertyResolver.colorOrNull(props, 'color') ??
        PropertyResolver.colorOrNull(style, 'color');
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 10;
    final padding = PropertyResolver.paddingFrom(style);
    final margin = PropertyResolver.marginFrom(style);
    final iconName = props['icon'] as String?;

    void handleTap() {
      final ev =
          node.events['onTap'] ??
          node.events['onPressed'] ??
          node.events['onClick'];
      if (ev is Map) {
        context.dispatchAction(Map<String, dynamic>.from(ev as Map));
      } else if (ev is String) {
        context.dispatchActionType(ev);
      } else if (props.containsKey('action')) {
        final a = props['action'];
        if (a is Map)
          context.dispatchAction(Map<String, dynamic>.from(a as Map));
        if (a is String) context.dispatchActionType(a);
      } else {
        // fallback snackbar
        ScaffoldMessenger.of(context.context)
            .showSnackBar(SnackBar(content: Text('Tapped: $text')));
      }
    }

    Widget btn;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    if (variant == 'outlined') {
      btn = OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: shape,
          foregroundColor: fg,
          side: BorderSide(color: bg ?? context.theme.primaryColor),
        ),
        onPressed: handleTap,
        child: _label(text, iconName),
      );
    } else if (variant == 'text') {
      btn = TextButton(
        style: TextButton.styleFrom(shape: shape, foregroundColor: fg),
        onPressed: handleTap,
        child: _label(text, iconName),
      );
    } else {
      btn = ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: shape,
          backgroundColor: bg ?? context.theme.primaryColor,
          foregroundColor: fg ?? Colors.white,
        ),
        onPressed: handleTap,
        child: _label(text, iconName),
      );
    }

    if (padding != EdgeInsets.zero) btn = Padding(padding: padding, child: btn);
    if (margin != EdgeInsets.zero) btn = Padding(padding: margin, child: btn);
    return btn;
  }

  Widget _label(String text, String? icon) {
    if (icon == null) return Text(text);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_iconData(icon), size: 18),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  IconData _iconData(String name) {
    switch (name) {
      case 'add':
        return Icons.add;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'check':
        return Icons.check;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.touch_app;
    }
  }

  @override
  List<PropDescriptor> get propDescriptors => const [
    PropDescriptor(
      key: 'text',
      label: 'Text',
      type: 'string',
      defaultValue: 'Button',
    ),
    PropDescriptor(
      key: 'variant',
      label: 'Variant',
      type: 'enum',
      enumValues: ['elevated', 'outlined', 'text'],
    ),
  ];
}
