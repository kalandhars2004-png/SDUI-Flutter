import 'package:flutter/material.dart';

import '../core/ui_node.dart';
import '../renderer/component_renderer.dart';
import '../renderer/render_context.dart';
import '../resolvers/property_resolver.dart';

class ColumnRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final main = PropertyResolver.mainAxisFrom(
      props['mainAxisAlignment'] ?? style['mainAxisAlignment'],
    );
    final cross = PropertyResolver.crossAxisFrom(
      props['crossAxisAlignment'] ?? style['crossAxisAlignment'],
      CrossAxisAlignment.start,
    );
    final spacing =
        PropertyResolver.doubleOrNull(style, 'gap') ??
        PropertyResolver.doubleOrNull(props, 'spacing') ??
        0;
    final padding = PropertyResolver.paddingFrom(style);
    final margin = PropertyResolver.marginFrom(style);

    List<Widget> kids = node.children.map(childRenderer).toList();
    if (spacing > 0 && kids.length > 1) {
      final spaced = <Widget>[];
      for (var i = 0; i < kids.length; i++) {
        spaced.add(kids[i]);
        if (i != kids.length - 1) spaced.add(SizedBox(height: spacing));
      }
      kids = spaced;
    }
    Widget w = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: main,
      crossAxisAlignment: cross,
      children: kids,
    );
    if (padding != EdgeInsets.zero) w = Padding(padding: padding, child: w);
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class RowRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final main = PropertyResolver.mainAxisFrom(
      props['mainAxisAlignment'] ?? style['mainAxisAlignment'],
    );
    final cross = PropertyResolver.crossAxisFrom(
      props['crossAxisAlignment'] ?? style['crossAxisAlignment'],
    );
    final spacing =
        PropertyResolver.doubleOrNull(style, 'gap') ??
        PropertyResolver.doubleOrNull(props, 'spacing') ??
        0;
    final padding = PropertyResolver.paddingFrom(style);
    final margin = PropertyResolver.marginFrom(style);

    List<Widget> kids = node.children.map(childRenderer).toList();
    if (spacing > 0 && kids.length > 1) {
      final spaced = <Widget>[];
      for (var i = 0; i < kids.length; i++) {
        spaced.add(Expanded(child: kids[i]));
        // Actually row spacing via SizedBox? If expanded, gap handled. For simplicity use Flexible.
      }
      // simpler: use spacing widgets without Expanded default
      kids = [];
      final orig = node.children.map(childRenderer).toList();
      for (var i = 0; i < orig.length; i++) {
        kids.add(orig[i]);
        if (i != orig.length - 1) kids.add(SizedBox(width: spacing));
      }
    }
    // If no spacing expansion logic used, keep original
    // Already handled above.

    Widget w = Row(
      mainAxisAlignment: main,
      crossAxisAlignment: cross,
      children: kids
          .map((e) => e is Expanded ? e : Flexible(child: e))
          .toList(),
    );
    // Actually to avoid Flexible wrapping breaking layout, we should not auto-wrap. Let's rebuild properly:
    // Re-evaluate: simpler row without forced flexible
    List<Widget> finalKids = node.children.map(childRenderer).toList();
    if (spacing > 0) {
      final tmp = <Widget>[];
      for (var i = 0; i < finalKids.length; i++) {
        tmp.add(finalKids[i]);
        if (i != finalKids.length - 1) tmp.add(SizedBox(width: spacing));
      }
      finalKids = tmp;
    }
    w = Row(
      mainAxisAlignment: main,
      crossAxisAlignment: cross,
      children: finalKids,
    );
    if (padding != EdgeInsets.zero) w = Padding(padding: padding, child: w);
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return SingleChildScrollView(scrollDirection: Axis.horizontal, child: w);
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class ContainerRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final props = node.props;
    final style = node.style;
    final color =
        PropertyResolver.colorOrNull(style, 'color') ??
        PropertyResolver.colorOrNull(style, 'backgroundColor') ??
        PropertyResolver.colorOrNull(props, 'color');
    final radius = PropertyResolver.borderRadiusFrom(style);
    final borderColor = PropertyResolver.colorOrNull(style, 'borderColor');
    final borderWidth = PropertyResolver.doubleOrNull(style, 'borderWidth');
    final width =
        PropertyResolver.doubleOrNull(props, 'width') ??
        PropertyResolver.doubleOrNull(style, 'width');
    final height =
        PropertyResolver.doubleOrNull(props, 'height') ??
        PropertyResolver.doubleOrNull(style, 'height');
    final padding = PropertyResolver.paddingFrom(style);
    final margin = PropertyResolver.marginFrom(style);
    final alignment = style['alignment'] != null
        ? PropertyResolver.alignmentFrom(style['alignment'], Alignment.topLeft)
        : null;

    Widget? child;
    if (node.children.isNotEmpty) {
      if (node.children.length == 1)
        child = childRenderer(node.children.first);
      else
        child = Column(
          mainAxisSize: MainAxisSize.min,
          children: node.children.map(childRenderer).toList(),
        );
    } else if (props['text'] != null) {
      child = Text(props['text'].toString());
    }

    Widget w = Container(
      width: width,
      height: height,
      alignment: alignment,
      padding: padding == EdgeInsets.zero ? null : padding,
      margin: margin == EdgeInsets.zero ? null : margin,
      decoration: BoxDecoration(
        color: color ?? Colors.transparent,
        borderRadius: radius != null ? BorderRadius.circular(radius) : null,
        border: borderColor != null
            ? Border.all(color: borderColor, width: borderWidth ?? 1)
            : null,
      ),
      child: child,
    );

    final onTap = node.events['onTap'];
    if (onTap != null) {
      w = InkWell(
        borderRadius: radius != null ? BorderRadius.circular(radius) : null,
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

class PaddingRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final style = node.style;
    final props = node.props;
    final pad = PropertyResolver.paddingFrom(style) != EdgeInsets.zero
        ? PropertyResolver.paddingFrom(style)
        : PropertyResolver.paddingFrom(props);
    // also allow direct props.padding numeric
    final pad2 = pad == EdgeInsets.zero && props['padding'] is num
        ? EdgeInsets.all((props['padding'] as num).toDouble())
        : pad;
    final child = node.children.isEmpty
        ? const SizedBox.shrink()
        : node.children.length == 1
        ? childRenderer(node.children.first)
        : Column(children: node.children.map(childRenderer).toList());
    return Padding(padding: pad2, child: child);
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class CenterRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final child = node.children.isEmpty
        ? const SizedBox.shrink()
        : node.children.length == 1
        ? childRenderer(node.children.first)
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: node.children.map(childRenderer).toList(),
          );
    return Center(child: child);
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class StackRenderer implements ComponentRenderer {
  @override
  Widget render(
    UiNode node,
    RenderContext context,
    Widget Function(UiNode) childRenderer,
  ) {
    final style = node.style;
    final alignment = PropertyResolver.alignmentFrom(
      style['alignment'],
      Alignment.topLeft,
    );
    return Stack(
      alignment: alignment,
      children: node.children.map(childRenderer).toList(),
    );
  }

  @override
  List<PropDescriptor> get propDescriptors => const [];
}
