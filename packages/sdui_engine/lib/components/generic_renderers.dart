import 'package:flutter/material.dart';
import '../core/ui_node.dart';
import '../renderer/component_renderer.dart';
import '../renderer/render_context.dart';
import '../resolvers/property_resolver.dart';

class SingleChildScrollViewRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final style = node.style;
    final scrollDirection = PropertyResolver.string(props, 'scrollDirection', PropertyResolver.string(style, 'scrollDirection', 'vertical'));
    final isHorizontal = scrollDirection == 'horizontal';
    final padding = PropertyResolver.paddingFrom(style) != EdgeInsets.zero ? PropertyResolver.paddingFrom(style) : PropertyResolver.paddingFrom(props);
    final margin = PropertyResolver.marginFrom(style);

    Widget child;
    if (node.children.isEmpty) child = const SizedBox.shrink();
    else if (node.children.length == 1) child = childRenderer(node.children.first);
    else child = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: node.children.map(childRenderer).toList());

    if (padding != EdgeInsets.zero) child = Padding(padding: padding, child: child);
    Widget w = SingleChildScrollView(scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical, child: child);
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class WrapRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final style = node.style;
    final spacing = PropertyResolver.doubleOrNull(props, 'spacing') ?? PropertyResolver.doubleOrNull(style, 'spacing') ?? 8;
    final runSpacing = PropertyResolver.doubleOrNull(props, 'runSpacing') ?? spacing;
    final padding = PropertyResolver.paddingFrom(style);
    Widget w = Wrap(spacing: spacing, runSpacing: runSpacing, children: node.children.map(childRenderer).toList());
    if (padding != EdgeInsets.zero) w = Padding(padding: padding, child: w);
    return w;
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class AlignRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final style = node.style;
    final props = node.props;
    final alignment = PropertyResolver.alignmentFrom(style['alignment'] ?? props['alignment'], Alignment.center);
    final child = node.children.isEmpty ? const SizedBox.shrink() : node.children.length == 1 ? childRenderer(node.children.first) : Column(children: node.children.map(childRenderer).toList());
    Widget w = Align(alignment: alignment, child: child);
    final margin = PropertyResolver.marginFrom(style);
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class ExpandedRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final flex = PropertyResolver.intVal(node.props, 'flex', PropertyResolver.intVal(node.style, 'flex', 1));
    final child = node.children.isEmpty ? const SizedBox.shrink() : node.children.length == 1 ? childRenderer(node.children.first) : Column(children: node.children.map(childRenderer).toList());
    // Expanded must be inside Flex; we provide Flexible as fallback if not.
    return Flexible(flex: flex, child: child);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class FlexibleRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final flex = PropertyResolver.intVal(node.props, 'flex', 1);
    final fit = PropertyResolver.string(node.props, 'fit', 'loose') == 'tight' ? FlexFit.tight : FlexFit.loose;
    final child = node.children.isEmpty ? const SizedBox.shrink() : node.children.length == 1 ? childRenderer(node.children.first) : Column(children: node.children.map(childRenderer).toList());
    return Flexible(flex: flex, fit: fit, child: child);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class CircleAvatarRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final style = node.style;
    final radius = PropertyResolver.doubleOrNull(props, 'radius') ?? PropertyResolver.doubleOrNull(style, 'radius') ?? 24;
    final bg = PropertyResolver.colorOrNull(props, 'backgroundColor') ?? PropertyResolver.colorOrNull(style, 'backgroundColor') ?? Colors.grey.shade300;
    final fg = PropertyResolver.colorOrNull(props, 'foregroundColor') ?? Colors.white;
    final text = PropertyResolver.string(props, 'text', PropertyResolver.string(props, 'child', ''));
    final imageSrc = PropertyResolver.string(props, 'src', PropertyResolver.string(props, 'image', ''));
    final margin = PropertyResolver.marginFrom(style);
    Widget w;
    if (imageSrc.isNotEmpty && imageSrc.startsWith('http')) {
      w = CircleAvatar(radius: radius, backgroundColor: bg, backgroundImage: NetworkImage(imageSrc), onBackgroundImageError: (_, __) {});
    } else if (text.isNotEmpty) {
      w = CircleAvatar(radius: radius, backgroundColor: bg, child: Text(text.length > 2 ? text.substring(0, 2).toUpperCase() : text.toUpperCase(), style: TextStyle(color: fg, fontWeight: FontWeight.w600)));
    } else if (node.children.isNotEmpty) {
      w = CircleAvatar(radius: radius, backgroundColor: bg, child: childRenderer(node.children.first));
    } else {
      w = CircleAvatar(radius: radius, backgroundColor: bg, child: Icon(Icons.person, color: fg, size: radius));
    }
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class ListTileRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final style = node.style;
    final title = PropertyResolver.string(props, 'title', PropertyResolver.string(props, 'text', ''));
    final subtitle = PropertyResolver.string(props, 'subtitle', '');
    final leadingIcon = PropertyResolver.string(props, 'leadingIcon', PropertyResolver.string(props, 'leading', ''));
    final trailingIcon = PropertyResolver.string(props, 'trailingIcon', PropertyResolver.string(props, 'trailing', ''));
    final dense = PropertyResolver.boolVal(props, 'dense', false);
    final margin = PropertyResolver.marginFrom(style);
    Widget? leading;
    if (leadingIcon.isNotEmpty) leading = Icon(_iconFor(leadingIcon), size: 22, color: const Color(0xFF334155));
    else if (props['leading'] is Map) leading = childRenderer(UiNode.fromJson(Map<String, dynamic>.from(props['leading'] as Map)));

    Widget? trailing;
    if (trailingIcon.isNotEmpty) trailing = Icon(_iconFor(trailingIcon), size: 20, color: Colors.grey.shade500);

    Widget w = Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      margin: margin == EdgeInsets.zero ? const EdgeInsets.symmetric(vertical: 4) : margin,
      child: ListTile(leading: leading, title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)) : null, trailing: trailing, dense: dense, onTap: () {
        final ev = node.events['onTap'];
        if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map));
        else if (ev is String) context.dispatchActionType(ev);
      }),
    );
    if (node.children.isNotEmpty) {
      w = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, ...node.children.map(childRenderer)]);
    }
    return w;
  }

  IconData _iconFor(String n) {
    switch (n.toLowerCase()) {
      case 'dashboard': return Icons.dashboard;
      case 'widgets': return Icons.widgets;
      case 'edit': return Icons.edit;
      case 'person': return Icons.person;
      case 'settings': return Icons.settings;
      default: return Icons.circle;
    }
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class ElevatedButtonRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final style = node.style;
    final label = PropertyResolver.string(props, 'label', PropertyResolver.string(props, 'text', 'Button'));
    final bg = PropertyResolver.colorOrNull(props, 'backgroundColor') ?? PropertyResolver.colorOrNull(style, 'backgroundColor');
    final radius = PropertyResolver.borderRadiusFrom(style) ?? 10;
    void onTap() {
      final ev = node.events['onTap'] ?? node.events['onPressed'];
      if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map));
      else if (ev is String) context.dispatchActionType(ev);
      else ScaffoldMessenger.of(context.context).showSnackBar(SnackBar(content: Text('Tapped: $label')));
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: bg ?? const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius))),
      onPressed: onTap,
      child: Text(label),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class TextButtonRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final label = PropertyResolver.string(props, 'label', PropertyResolver.string(props, 'text', 'Button'));
    final radius = PropertyResolver.borderRadiusFrom(node.style) ?? 8;
    void onTap() {
      final ev = node.events['onTap'] ?? node.events['onPressed'];
      if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map));
      else if (ev is String) context.dispatchActionType(ev);
      else ScaffoldMessenger.of(context.context).showSnackBar(SnackBar(content: Text('Tapped: $label')));
    }
    return TextButton(style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius))), onPressed: onTap, child: Text(label));
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class IconButtonRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final iconName = PropertyResolver.string(props, 'icon', PropertyResolver.string(props, 'iconName', 'star'));
    final color = PropertyResolver.colorOrNull(props, 'color') ?? const Color(0xFF0F172A);
    final size = PropertyResolver.doubleOrNull(props, 'size') ?? 24;
    void onTap() {
      final ev = node.events['onTap'] ?? node.events['onPressed'];
      if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map));
      else if (ev is String) context.dispatchActionType(ev);
    }
    return IconButton(icon: Icon(_iconFor(iconName), size: size, color: color), onPressed: onTap);
  }
  IconData _iconFor(String n) {
    switch (n.toLowerCase()) {
      case 'dashboard': return Icons.dashboard;
      case 'favorite': return Icons.favorite;
      case 'add': return Icons.add;
      default: return Icons.star;
    }
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class FloatingActionButtonRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final iconName = PropertyResolver.string(props, 'icon', 'add');
    final bg = PropertyResolver.colorOrNull(props, 'backgroundColor') ?? const Color(0xFF0F172A);
    void onTap() {
      final ev = node.events['onTap'] ?? node.events['onPressed'];
      if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map));
      else if (ev is String) context.dispatchActionType(ev);
    }
    final fab = FloatingActionButton.small(backgroundColor: bg, onPressed: onTap, child: Icon(_iconFor(iconName), color: Colors.white));
    // FloatingActionButton cannot be freely placed in column; wrap with Align to avoid layout issues
    return Align(alignment: Alignment.centerRight, child: fab);
  }
  IconData _iconFor(String n) => n == 'add' ? Icons.add : Icons.star;
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class TextFieldRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final label = PropertyResolver.string(props, 'label', PropertyResolver.string(props, 'hint', ''));
    final hint = PropertyResolver.string(props, 'hint', PropertyResolver.string(props, 'placeholder', ''));
    final value = PropertyResolver.string(props, 'value', '');
    final enabled = PropertyResolver.boolVal(props, 'enabled', true);
    final margin = PropertyResolver.marginFrom(node.style);
    final radius = PropertyResolver.borderRadiusFrom(node.style) ?? 10;
    Widget w = TextField(
      enabled: enabled,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label.isNotEmpty ? label : null,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onChanged: (v) {
        final ev = node.events['onChanged'] ?? node.events['onTap'];
        if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map));
      },
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class CheckboxRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final title = PropertyResolver.string(props, 'title', PropertyResolver.string(props, 'label', 'Check'));
    final value = PropertyResolver.boolVal(props, 'value', false);
    final enabled = PropertyResolver.boolVal(props, 'enabled', true);
    return Row(children: [
      Checkbox(value: value, onChanged: enabled ? (v) {
        final ev = node.events['onChanged'];
        if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map));
        else if (ev is String) context.dispatchActionType(ev);
      } : null),
      Text(title, style: const TextStyle(fontSize: 13)),
      if (node.children.isNotEmpty) Expanded(child: Column(children: node.children.map(childRenderer).toList())),
    ]);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class DropdownButtonRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final itemsRaw = props['items'];
    List<String> items = [];
    if (itemsRaw is List) items = itemsRaw.map((e) => e.toString()).toList();
    else items = ['Option 1', 'Option 2'];
    final value = PropertyResolver.string(props, 'value', items.isNotEmpty ? items.first : '');
    final hint = PropertyResolver.string(props, 'hint', 'Select');
    final margin = PropertyResolver.marginFrom(node.style);
    Widget w = DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      hint: Text(hint),
      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) {
        final ev = node.events['onChanged'];
        if (ev is Map) context.dispatchAction(Map<String, dynamic>.from(ev as Map));
        else if (ev is String) context.dispatchActionType(ev);
      },
    );
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class CircularProgressRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final value = PropertyResolver.doubleOrNull(props, 'value');
    final color = PropertyResolver.colorOrNull(props, 'color') ?? const Color(0xFF0F172A);
    final size = PropertyResolver.doubleOrNull(props, 'size') ?? 36;
    Widget w = SizedBox(width: size, height: size, child: CircularProgressIndicator(value: value, color: color));
    final margin = PropertyResolver.marginFrom(node.style);
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return Center(child: w);
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class LinearProgressRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final value = PropertyResolver.doubleOrNull(props, 'value');
    final color = PropertyResolver.colorOrNull(props, 'color') ?? const Color(0xFF0F172A);
    final margin = PropertyResolver.marginFrom(node.style);
    Widget w = LinearProgressIndicator(value: value, color: color, backgroundColor: Colors.grey.shade200);
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class ListViewRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final isHorizontal = PropertyResolver.string(props, 'scrollDirection', 'vertical') == 'horizontal';
    final children = node.children.map(childRenderer).toList();
    if (children.isEmpty) return const SizedBox.shrink();
    // Use shrinkWrap + physics to avoid unbounded height issues inside column
    return SizedBox(
      height: isHorizontal ? 120 : null,
      child: ListView(
        scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      ),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class GridViewRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final crossAxisCount = PropertyResolver.intVal(props, 'crossAxisCount', 2);
    final mainSpacing = PropertyResolver.doubleOrNull(props, 'mainAxisSpacing') ?? 8;
    final crossSpacing = PropertyResolver.doubleOrNull(props, 'crossAxisSpacing') ?? 8;
    final children = node.children.map(childRenderer).toList();
    if (children.isEmpty) return const SizedBox.shrink();
    return GridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainSpacing,
      crossAxisSpacing: crossSpacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class SearchBarRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final hint = PropertyResolver.string(props, 'hint', PropertyResolver.string(props, 'placeholder', 'Search'));
    final margin = PropertyResolver.marginFrom(node.style);
    Widget w = SearchBar(hintText: hint, leading: const Icon(Icons.search), padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)), elevation: const WidgetStatePropertyAll(1));
    if (margin != EdgeInsets.zero) w = Padding(padding: margin, child: w);
    return w;
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class BottomNavigationBarRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final props = node.props;
    final itemsRaw = props['items'];
    List<Map<String, dynamic>> items;
    if (itemsRaw is List) items = itemsRaw.whereType<Map>().map((e) => Map<String, dynamic>.from(e as Map)).toList();
    else items = [{'label':'Home','icon':'home'},{'label':'Search','icon':'search'},{'label':'Profile','icon':'person'}];
    return Container(
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: items.map((it) {
        final label = (it['label'] ?? '').toString();
        final icon = (it['icon'] ?? 'home').toString();
        return Column(mainAxisSize: MainAxisSize.min, children: [Icon(_iconFor(icon), size: 20, color: const Color(0xFF0F172A)), const SizedBox(height: 2), Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF334155)))]);
      }).toList()),
    );
  }
  IconData _iconFor(String n) {
    switch(n) {
      case 'home': return Icons.home;
      case 'search': return Icons.search;
      case 'person': return Icons.person;
      default: return Icons.circle;
    }
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}

class DrawerRenderer implements ComponentRenderer {
  @override
  Widget render(UiNode node, RenderContext context, Widget Function(UiNode) childRenderer) {
    final children = node.children.map(childRenderer).toList();
    return Container(
      width: 280,
      decoration: BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: Colors.grey.shade200))),
      child: ListView(padding: const EdgeInsets.symmetric(vertical: 12), children: children.isEmpty ? [ListTile(title: Text('Drawer'), leading: Icon(Icons.menu))] : children),
    );
  }
  @override
  List<PropDescriptor> get propDescriptors => const [];
}
