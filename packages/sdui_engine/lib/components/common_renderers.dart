import 'package:flutter/material.dart';

import '../core/ui_node.dart';
import '../renderer/component_renderer.dart';
import '../renderer/render_context.dart';
import '../resolvers/property_resolver.dart';

class IconRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final name = PropertyResolver.string(
      props,
      'icon',
      PropertyResolver.string(props, 'name', 'star'),
    );
    final size =
        PropertyResolver.doubleOrNull(props, 'size') ??
        PropertyResolver.doubleOrNull(style, 'size') ??
        24;
    final color =
        PropertyResolver.colorOrNull(props, 'color') ??
        PropertyResolver.colorOrNull(style, 'color') ??
        context.theme.textColor;
    final margin = PropertyResolver.marginFrom(style);
    Widget w = Icon(_iconFor(name), size: size, color: color);
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    final onTap = node.events['onTap'];
    if (onTap != null) {
      w = InkWell(
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

  IconData _iconFor(String name) {
    switch (name) {
      case 'home':
        return Icons.home;
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      case 'person':
        return Icons.person;
      case 'settings':
        return Icons.settings;
      case 'search':
        return Icons.search;
      case 'add':
        return Icons.add;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'check':
        return Icons.check;
      case 'info':
        return Icons.info;
      case 'warning':
        return Icons.warning;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'menu':
        return Icons.menu;
      case 'close':
        return Icons.close;
      case 'delete':
        return Icons.delete;
      case 'edit':
        return Icons.edit;
      case 'calendar_today':
        return Icons.calendar_today;
      default:
        return Icons.circle;
    }
  }

  @override
  List<PropDescriptor> get propDescriptors => const [
    PropDescriptor(
      key: 'icon',
      label: 'Icon',
      type: 'enum',
      enumValues: [
        'home',
        'star',
        'favorite',
        'person',
        'settings',
        'search',
        'add',
      ],
    ),
    PropDescriptor(
      key: 'size',
      label: 'Size',
      type: 'number',
      defaultValue: 24,
    ),
  ];
}

class DividerRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final thickness =
        PropertyResolver.doubleOrNull(props, 'thickness') ??
        PropertyResolver.doubleOrNull(style, 'thickness') ??
        1;
    final color =
        PropertyResolver.colorOrNull(props, 'color') ??
        PropertyResolver.colorOrNull(style, 'color') ??
        Colors.grey.shade300;
    final indent = PropertyResolver.doubleOrNull(props, 'indent') ?? 0;
    final endIndent = PropertyResolver.doubleOrNull(props, 'endIndent') ?? 0;
    final margin = PropertyResolver.marginFrom(style);
    Widget w = Divider(
      thickness: thickness,
      color: color,
      indent: indent,
      endIndent: endIndent,
      height: thickness + 16,
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class ListRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final direction = PropertyResolver.string(
      props,
      'direction',
      PropertyResolver.string(style, 'direction', 'vertical'),
    );
    final spacing =
        PropertyResolver.doubleOrNull(props, 'spacing') ??
        PropertyResolver.doubleOrNull(style, 'gap') ??
        8;
    final scrollable = PropertyResolver.boolVal(props, 'scrollable', false);
    final children = node.children.map(childRenderer).toList();

    List<Widget> spaced;
    if (direction == 'horizontal') {
      spaced = [];
      for (var i = 0; i < children.length; i++) {
        spaced.add(children[i]);
        if (i != children.length - 1) spaced.add(SizedBox(width: spacing));
      }
      Widget row = Row(children: spaced);
      if (scrollable)
        row = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: row,
        );
      return row;
    } else {
      spaced = [];
      for (var i = 0; i < children.length; i++) {
        spaced.add(children[i]);
        if (i != children.length - 1) spaced.add(SizedBox(height: spacing));
      }
      Widget col = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: spaced,
      );
      if (scrollable) col = SingleChildScrollView(child: col);
      return col;
    }
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class SizedBoxRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final w =
        PropertyResolver.doubleOrNull(props, 'width') ??
        PropertyResolver.doubleOrNull(style, 'width');
    final h =
        PropertyResolver.doubleOrNull(props, 'height') ??
        PropertyResolver.doubleOrNull(style, 'height') ??
        PropertyResolver.doubleOrNull(props, 'h') ??
        16;
    return SizedBox(width: w, height: h);
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}
